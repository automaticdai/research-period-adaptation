#include <math.h>

#include "afbs.h"
#include "app.h"

int AFBS_PERIOD = 10;

int TASK_1_PERIOD = 0; // normal
int TASK_2_PERIOD = 0; // slowest
int TASK_3_PERIOD = 0; // adapative

int TASK_1_IDX = 6;

int task_config[TASK_NUMBERS][5] = {
{0, 1, 1, 0, 0},
{1, 1, 12, 0, 0},
{2, 2, 12, 0, 0},
{3, 2, 15, 0, 0},
{4, 2, 20, 0, 0},
{5, 1, 10, 0, 0},
{6, 1, 100, 0, 0}
};

void task_init(void) {

    for (int i = 0; i < TASK_NUMBERS; i++) {
        class Task t1(task_config[i][0], task_config[i][1], task_config[i][2],
                    task_config[i][3], task_config[i][4]);
        afbs_create_task(t1, NULL, NULL, NULL);
    }

    /* override some tasks for afbs and control tasks */
    class Task afbs_task(0, 1, AFBS_PERIOD, 0, 0);
    afbs_create_task(afbs_task, NULL, afbs_start_hook, NULL);

    TASK_1_PERIOD = afbs_get_param(0);
    TASK_2_PERIOD = afbs_get_param(1);
    TASK_3_PERIOD = afbs_get_param(2);

    class Task tau1(TASK_1_IDX, 2, TASK_1_PERIOD, 0, 0);
    //class Task tau2(7, 20, TASK_2_PERIOD, 0, 0);
    //class Task tau3(8, 20, TASK_3_PERIOD, 0, 0);
    afbs_create_task(tau1, NULL, task_1_start_hook, task_1_finish_hook);
    //afbs_create_task(tau2, NULL, task_2_start_hook, task_2_finish_hook);
    //afbs_create_task(tau3, NULL, task_3_start_hook, task_3_finish_hook);

    mexPrintf("t_stamp, tss, j_cost \r");

    return;
}


/*-- afbs task ---------------------------------------------------------------*/
int    t_period = 100;

double ref_last = 0;
double ref_this = 0;
double ref_diff = 0; // difference between references, used to normalize PI

int    y_idx = 0;
double y_trace[1000];

int    pi_idx = 0;
double pi_trace[100];

double tss = -1;
double tss_target = 0.28;

double cost = 0;

double analysis_steady_state_time(void) {
    int tss_idx = 0;

    for (int i = 0; i < y_idx; i++) {
        // 0.2 is steady-state error
        if ((y_trace[i] > ref_last + 0.05) || (y_trace[i] < ref_last - 0.05)) {
            tss_idx = i;
        }
    }

    cost = 0;
    for (int i = 0; i < tss_idx; i++) {
        cost += (y_trace[i] - ref_last) / abs(ref_diff)
                * (y_trace[i] - ref_last) / abs(ref_diff);
    }

    return double(tss_idx) * KERNEL_TICK_TIME * AFBS_PERIOD;
}


void afbs_start_hook(void) {
    // evaluate system performance
    y_trace[y_idx] = afbs_state_in_load(0);
    y_idx += 1;

    ref_this = afbs_state_ref_load(0);

    /* check if the reference has changed */
    if (ref_this != ref_last) {
        tss = analysis_steady_state_time();
        mexPrintf("%f, %f, %f \r", afbs_get_current_time(), tss, cost);

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


/*-- control tasks -----------------------------------------------------------*/
double ref;
double y;
void task_1_start_hook(void) {
    ref = afbs_state_ref_load(0);
    y = afbs_state_in_load(0);
    return;
}

void task_1_finish_hook(void) {
    double N = 0.1005;
    double K = 0.0499;
    double C = 100;

    double x = y / C;
    double u = -1 * K * x + N * ref;
    afbs_state_out_set(0, u);
    return;
}


void task_2_start_hook(void) {
    return;
}

void task_2_finish_hook(void) {
    return;
}


void task_3_start_hook(void) {
    return;
}

void task_3_finish_hook(void) {
    return;
}
