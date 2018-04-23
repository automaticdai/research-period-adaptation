#include <stddef.h>
#include <math.h>

#include "simstruc.h"

#include "afbs.h"

//#define AFBS_DEBUG_ON   (1)
#define AFBS_WARNING_ON (1)

CTask TCB[TASK_MAX_NUM];
//enum_task_status task_status_list[TASK_MAX_NUM];

//bool ready_q[TASK_MAX_NUM];
//bool pending_q[TASK_MAX_NUM];

long   kernel_cnt;
long   idle_cnt;
int    tcb_running_id;
int    step_count = 0;

/* system states */
double states_ref[STATES_REF_NUM];
double states_in[STATES_IN_NUM];
double states_out[STATES_OUT_NUM];

/* s-func parameters from Simulink */
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
    mexPrintf("\r");
}

long afbs_get_kernel_cnt(void)
{
    return kernel_cnt;
}

long afbs_get_idle_cnt(void)
{
    return idle_cnt;
}

double afbs_get_current_time(void)
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
    kernel_cnt = 0;
    idle_cnt = 0;
}

void afbs_create_task(CTask t, callback task_main, callback on_start, callback on_finish)
{
    if (t.T_ == 0) {
        #ifdef AFBS_WARNING_ON
            mexPrintf("Error: Task period cannot be 0!\r");
        #endif
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
    for (int i = 0; i < TASK_MAX_NUM; i++) {
        if (TCB[i].status_ != deleted) {
            if (TCB[i].r_-- == 0) {
                // check if a task missed its deadline
                if (TCB[i].c_ != 0) {
                    TCB[i].on_task_missed_deadline();
                    #ifdef AFBS_WARNING_ON
                        mexPrintf("[%0.4f] Task %d deadline missed! \r", afbs_get_current_time(), i);
                    #endif
                } else {
                    TCB[i].status_ = ready;
                    TCB[i].on_task_ready();
                    #ifdef AFBS_DEBUG_ON
                        mexPrintf("[%0.4f] Task %d ready! \r", afbs_get_current_time(), i);
                    #endif
                }
            }
        }
    }

    // if current task is finished, set current task to IDLE
    if (TCB[tcb_running_id].c_ == 0) {
        tcb_running_id = IDLE_TASK_IDX;
    }
}

void  afbs_schedule(void) {
    int task_to_be_scheduled = IDLE_TASK_IDX;

    // find the next task to run
    for (int i = 0; i < TASK_MAX_NUM; i++)
    {
        if ((TCB[i].status_ == ready) || (TCB[i].status_ == pending)) {
            task_to_be_scheduled = i;
            break;
        }
    }

    // set lower-priority tasks to pending
    if ((task_to_be_scheduled != IDLE_TASK_IDX)) {
        for (int i = task_to_be_scheduled + 1; i < TASK_MAX_NUM; i++) {
            if (TCB[i].status_ == ready) {
                TCB[i].status_ = pending;
            }
        }
    }

    // run task scheduled hook
    if ((task_to_be_scheduled != IDLE_TASK_IDX) &&
       (TCB[task_to_be_scheduled].c_ == TCB[task_to_be_scheduled].C_)) {
        TCB[task_to_be_scheduled].on_task_start();
        #ifdef AFBS_DEBUG_ON
            mexPrintf("[%0.4f] Task %d started! \r", afbs_get_current_time(), task_to_be_scheduled);
        #endif
    }

    TCB[task_to_be_scheduled].status_ = ready;
    tcb_running_id = task_to_be_scheduled;
}

void afbs_run(void) {
    if (tcb_running_id != IDLE_TASK_IDX) {
        #ifdef AFBS_DEBUG_ON
            mexPrintf("[%0.4f] Running Task %d\r", afbs_get_current_time(), tcb_running_id);
        #endif
        kernel_cnt++;
        if (--TCB[tcb_running_id].c_ == 0) {
            TCB[tcb_running_id].status_ = waiting;
            TCB[tcb_running_id].on_task_finish();
            #ifdef AFBS_DEBUG_ON
                mexPrintf("[%0.4f] Task %d finished! \r", afbs_get_current_time(), tcb_running_id);
            #endif
        }
    }
    else {
        afbs_idle();
        kernel_cnt++;
    }

    /* run monitor */
    afbs_performance_monitor();
}

void afbs_idle(void)
{
    idle_cnt++;
}


/*----------------------------------------------------------------------------*/
/* Monitor Related                                                            */
/*----------------------------------------------------------------------------*/
int    t_period = 100;

double ref_last = 0;
double ref_this = 0;
double ref_diff = 0; // difference between references, used to normalize PI

#define TRACE_BUFFER_SIZE   (1000000L)
int    y_idx = 0;
double y_trace[TRACE_BUFFER_SIZE];

#define TRACE_PI_SIZE       (100)
int    pi_idx = 0;
double pi_trace[TRACE_PI_SIZE];

double tss = -1;
double tss_target = 0.28;

double cost_ISE = 0;
double cost_IAE = 0;

double analysis_steady_state_time(void) {
    int i = 0;
    int tss_idx = 0;

    for (i = 0; i < y_idx; i++) {
        // find when the system enters steady-state
        // 0.2 is steady-state error
        if ((y_trace[i] > ref_last + 0.02 * ref_last + 0.001) 
           || (y_trace[i] < ref_last - 0.02 * ref_last - 0.001)) {
            tss_idx = i;
        }
    }

    cost_ISE = 0;
    cost_IAE = 0;
    
    if (ref_diff == 0) {
        /* first operation, no ref_diff */
        ;
    } else {
        for (i = 0; i < tss_idx; i++) {
            cost_ISE += ((y_trace[i] - ref_last) / abs(ref_diff))
                 * ((y_trace[i] - ref_last) / abs(ref_diff)) * KERNEL_TICK_TIME;
            
            cost_IAE += abs(y_trace[i] - ref_last) / abs(ref_diff) * KERNEL_TICK_TIME;
        }
    }
    return double(tss_idx) * KERNEL_TICK_TIME;
}


void afbs_performance_monitor(void) {
    double C = 3.9528;
    
    double x1 = 0;
    double x2 = 0;
    // evaluate system performance
    x1 = afbs_state_in_load(0);
    x2 = afbs_state_in_load(1);
    y_trace[y_idx] = C * x1;

    if (y_idx < TRACE_BUFFER_SIZE - 1) {
        y_idx += 1;
    } else {
        #ifdef AFBS_WARNING_ON
            mexPrintf("Error: monitor overflowed! \r");
        #endif
    }

    ref_this = afbs_state_ref_load(0);

    /* check if the reference has changed */
    if (ref_this != ref_last) {
        tss = analysis_steady_state_time();
        mexPrintf("%f, %f, %f, %f, 0 \r", afbs_get_current_time(), tss, cost_ISE, cost_IAE);

        /* Policy 1 */
        /*
        if (abs(tss - tss_target) < 0.05) {
            // hold, no action;
        }
        else if (tss <= tss_target) {
            t_period += 5;
            afbs_set_task_period(TASK_1_IDX, t_period);
        } else {
            t_period -= 20;
            afbs_set_task_period(TASK_1_IDX, t_period);
        }
        */
        // end of policy

        /* Policy 2 */
        /*
        pi_trace[pi_idx] = tss;
        pi_idx += 1;

        if (pi_idx >= 100) {
            double tss_a = 0;
            for (int i = 0; i < 100; i++){
                tss_a += pi_trace[i];
            }
            tss = tss_a / 100;

            if (abs(tss - tss_target) < 0.01) {
                // hold, no action;
            }
            else if (tss <= tss_target) {
                t_period += 1;
                afbs_set_task_period(TASK_1_IDX, t_period);
            } else {
                t_period -= 1;
                afbs_set_task_period(TASK_1_IDX, t_period);
            }

            pi_idx = 0;
        }
        */
        // end of policy

        y_idx = 0;
        ref_diff = ref_this - ref_last;
    }

    ref_last = ref_this;

}


long afbs_report_task_last_response_time(int task_id) {
    return TCB[task_id].finish_time_cnt - TCB[task_id].release_time_cnt;
}
/*- EOF ----------------------------------------------------------------------*/
