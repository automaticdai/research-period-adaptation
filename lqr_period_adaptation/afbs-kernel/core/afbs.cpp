#include <stddef.h>
#include "simstruc.h"

#include "afbs.h"

CTask TCB[TASK_MAX_NUM];
//enum_task_status task_status_list[TASK_MAX_NUM];

//bool ready_q[TASK_MAX_NUM];
//bool pending_q[TASK_MAX_NUM];

long    kernel_cnt;
long    idle_cnt;
int     tcb_running_id;
int     step_count = 0;

/* system states */
double states_ref[STATES_REF_NUM];
double states_in[STATES_IN_NUM];
double states_out[STATES_OUT_NUM];
double param[PARAM_NUM];

/*----------------------------------------------------------------------------*/
/* Kernel Related                                                             */
/*----------------------------------------------------------------------------*/
void afbs_dump_information(void)
{
    mexPrintf("t: %d \r", kernel_cnt);
    mexPrintf("Current Task: %d \r", tcb_running_id);
    mexPrintf("\r Task TCB: \r");

    for (int i = 0; i < TASK_MAX_NUM; i++) {
        TCB[i].repr();
    }
    //cout << '\n';
}

long afbs_get_kernel_cnt(void)
{
    return kernel_cnt;
}

long afbs_get_idle_cnt(void)
{
    return idle_cnt;
}

float afbs_get_current_time(void)
{
    return kernel_cnt * KERNEL_TICK_TIME;
}


/*----------------------------------------------------------------------------*/
/* States Related                                                             */
/*----------------------------------------------------------------------------*/
void afbs_state_in_set(int idx, double value)
{
    states_in[idx] = value;
}

void afbs_state_ref_set(int idx, double value)
{
    states_ref[idx] = value;
}

void afbs_state_out_set(int idx, double value)
{
    states_out[idx] = value;
}

double afbs_state_in_load(int idx)
{
    return states_in[idx];
}

double afbs_state_ref_load(int idx)
{
    return states_ref[idx];
}

double afbs_state_out_load(int idx)
{
    return states_out[idx];
}

void afbs_set_param(int idx, double value)
{
    param[idx] = value;
}

double afbs_get_param(int idx)
{
    return param[idx];
}

/*----------------------------------------------------------------------------*/
/* Task Related                                                               */
/*----------------------------------------------------------------------------*/
void afbs_initilize(enum_scheduling_policy sp)
{
    int i = 0;
    for (; i < TASK_MAX_NUM; i++) {
        TCB[i].id_ = i;
        TCB[i].status_ = deleted;
    }
    tcb_running_id = IDLE_TASK_IDX;
    step_count = 0;
}

void afbs_create_task(CTask t, callback task_main, callback on_start, callback on_finish)
{
    if (t.T_ == 0) {
        mexPrintf("Error: Task period cannot be 0!\r");
        return;
    }

    if (t.R_ == 0) {
        t.status_ = ready;
        t.on_task_ready();
    }
    else {
        t.r_ = t.R_;
        t.status_ = waiting;
    }

    t.set_onstart_hook(on_start);
    t.set_onfinish_hook(on_finish);

    TCB[t.id_] = t;
}

void afbs_delete_task(int task_id)
{
    ;
}

void afbs_set_task_period(int task_id, int new_period)
{
    TCB[task_id].T_ = new_period;
}

int afbs_get_task_period(int task_id)
{
    return TCB[task_id].T_;
}

int afbs_get_running_task_id()
{
    return tcb_running_id;
}

int afbs_get_execution_time_left(int task_id)
{
    return TCB[task_id].c_;
}

void afbs_create_job(CTask j, int prio, callback job_main, callback on_start, callback on_finish)
{
    ;
}

// [debug]
void afbs_delete_job(int job_id)
{
    ;
}

void afbs_update(void)
{
    kernel_cnt++;

    for (int i = 0; i < TASK_MAX_NUM; i++) {
        if (TCB[i].status_ != deleted) {
            if (--TCB[i].r_ == 0) {
                TCB[i].status_ = ready;
                TCB[i].on_task_ready();
            }
        }
    }

    // if current task is finished, set current task to IDLE
    if (TCB[tcb_running_id].c_ == 0)
    {
        tcb_running_id = IDLE_TASK_IDX;
    }

    // feedback scheduling handler
    // a little bit hacking
    //if (kernel_cnt % (int)(AFBS_SAMPLING_PERIOD / KERNEL_TICK_TIME) == 0) {
        // state feedback
        //TCB[1].T_ = floor(TASK_1_PERIOD * pow(exp(1.0), (-10.0 * error[1])) + TASK_1_PERIOD);

        // dual-priority
        //if (error[2] > 0.3) {
        //if (step_count <= alpha * 1000) {
            /*
            if (TCB[2].T_ != 20) {
                TCB[2].r_ = 1;
            }*/
        //    TCB[0].T_ = TASK_1_PERIOD;
        //}
        //else {
        //    TCB[0].T_ = TASK_2_PERIOD;
        //}
        //step_count += 1;
    //}

}

void  afbs_schedule(void) {
    int task_to_be_scheduled = IDLE_TASK_IDX;

    for (int i = 0; i < TASK_MAX_NUM; i++)
    {
        if ((TCB[i].status_ == ready) || (TCB[i].status_ == pending)) {
            task_to_be_scheduled = i;
            break;
        }
    }

    if ((task_to_be_scheduled != IDLE_TASK_IDX)) {
        for (int i = task_to_be_scheduled + 1; i < TASK_MAX_NUM; i++) {
            if (TCB[i].status_ == ready) {
                TCB[i].status_ = pending;
            }
        }
    }

    // task scheduled hook
    if ((task_to_be_scheduled != tcb_running_id) &&
       (TCB[task_to_be_scheduled].c_ == TCB[task_to_be_scheduled].C_)) {
        TCB[task_to_be_scheduled].on_task_start();
    }

    TCB[task_to_be_scheduled].status_ = ready;
    tcb_running_id = task_to_be_scheduled;
}

void afbs_run(void) {
    if (tcb_running_id != IDLE_TASK_IDX) {
        if (--TCB[tcb_running_id].c_ == 0) {
            TCB[tcb_running_id].status_ = waiting;
            TCB[tcb_running_id].on_task_finish();
            //cout << 'f';
        }
    }
    else {
        afbs_idle();
    }
}

void afbs_idle(void)
{
    idle_cnt++;
}

/*- EOF ----------------------------------------------------------------------*/
