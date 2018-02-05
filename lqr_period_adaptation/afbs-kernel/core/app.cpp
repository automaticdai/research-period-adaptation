#include <math.h>

#include "afbs.h"
#include "app.h"

int AFBS_PERIOD = 10;

int TASK_1_PERIOD = 0; // normal
int TASK_2_PERIOD = 0; // slowest
int TASK_3_PERIOD = 0; // adapative

void task_init(void) {
    TASK_1_PERIOD = afbs_get_param(0);
    TASK_2_PERIOD = afbs_get_param(1);
    TASK_3_PERIOD = afbs_get_param(2);

    class Task afbs_task(0, 1, AFBS_PERIOD, 0, 0);

    class Task t1(1, 1, 11, 0, 0);
    class Task t2(2, 2, 12, 0, 0);
    class Task t3(3, 2, 15, 0, 0);
    class Task t4(4, 2, 20, 0, 0);
    class Task t5(5, 1, 10, 0, 0);

    class Task tau1(6, 10, TASK_1_PERIOD, 0, 0);
    //class Task tau2(7, 20, TASK_2_PERIOD, 0, 0);
    //class Task tau3(8, 20, TASK_3_PERIOD, 0, 0);


    afbs_create_task(afbs_task, NULL, afbs_start_hook, NULL);

    afbs_create_task(t1, NULL, NULL, NULL);
    afbs_create_task(t2, NULL, NULL, NULL);
    afbs_create_task(t3, NULL, NULL, NULL);
    afbs_create_task(t4, NULL, NULL, NULL);
    afbs_create_task(t5, NULL, NULL, NULL);

    afbs_create_task(tau1, NULL, task_1_start_hook, task_1_finish_hook);
    //afbs_create_task(tau2, NULL, task_2_start_hook, task_2_finish_hook);
    //afbs_create_task(tau3, NULL, task_3_start_hook, task_3_finish_hook);

    return;
}



/*-- afbs task ---------------------------------------------------------------*/
int    t_period = 100;

double ref_last = 0;
double ref_this = 0;

int    y_idx = 0;
double y_trace[1000];

int    pi_idx = 0;
double pi_trace[100];

double tss = -1;
double tss_target = 1.2;

double analysis_steady_state_time(void) {
    int tss_idx;

    for (int i = 0; i < y_idx; i++) {
        if ((y_trace[i] > ref_last + 0.2) || (y_trace[i] < ref_last - 0.2)) {
            tss_idx = i;
        }
    }
    return tss_idx * KERNEL_TICK_TIME * AFBS_PERIOD;
}


void afbs_start_hook(void) {
    // evaluate system performance
    y_trace[y_idx] = afbs_state_in_load(0);
    y_idx += 1;

    ref_this = afbs_state_ref_load(0);

    /* check if the reference has changed */
    if (ref_this != ref_last) {
        tss = analysis_steady_state_time();
        mexPrintf("%f, %f \r", afbs_get_current_time(), tss);

        pi_trace[pi_idx] = tss;
        pi_idx += 1;

        /* policy 1 */
        /*
        if (abs(tss - tss_target) < 0.05) {
            // hold, no action;
        }
        else if (tss <= tss_target) {
            t_period += 10;
            afbs_set_task_period(6, t_period);
        } else {
            t_period -= 10;
            afbs_set_task_period(6, t_period);
        }
        */
        /* policy 2 */

        if (pi_idx >= 5) {
            tss = (pi_trace[0] + pi_trace[1] + pi_trace[2] + pi_trace[3] + pi_trace[4]) / 5;

            if (abs(tss - tss_target) < 0.05) {
                // hold, no action;
            }
            else if (tss <= tss_target) {
                t_period += 50;
                afbs_set_task_period(6, t_period);
            } else {
                t_period -= 50;
                afbs_set_task_period(6, t_period);
            }

            pi_idx = 0;
        }
        

        y_idx = 0;
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
