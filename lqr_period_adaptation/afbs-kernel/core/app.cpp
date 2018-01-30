#include "afbs.h"
#include "app.h"

int TASK_1_PERIOD = 0; // normal
int TASK_2_PERIOD = 0; // slowest
int TASK_3_PERIOD = 0; // adapative

void task_init(void) {
    TASK_1_PERIOD = afbs_get_param(0);
    TASK_2_PERIOD = afbs_get_param(1);
    TASK_3_PERIOD = afbs_get_param(2);


    class Task afbs_task(0, 1, 10, 0, 100);
    class Task t1(1, 1, 10, 0, 0);
    class Task t2(2, 2, 12, 0, 0);
    class Task t3(3, 2, 15, 0, 0);
    class Task t4(4, 2, 20, 0, 0);
    class Task t5(5, 2, 25, 0, 0);


    class Task tau1(6, 10, TASK_1_PERIOD, 0, 0);
    //class Task tau2(4, 20, TASK_2_PERIOD, 0, 0);
    //class Task tau3(5, 20, TASK_3_PERIOD, 0, 0);


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

int    ref_idex = 0;
double ref_trace[1000];

int    y_idx = 0;
double y_trace[1000];

int    pi_idx = 0;
double pi_trace[1000];

void afbs_start_hook(void) {
    // evaluate system performance

    // make decision (actually on the cloud)
    afbs_set_task_period(6, t_period);
    t_period += 1;
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
