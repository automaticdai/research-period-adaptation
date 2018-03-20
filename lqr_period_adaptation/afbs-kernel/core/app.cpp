#include "afbs.h"
#include "app.h"

int TASK_1_PERIOD = 0; // normal
int TASK_2_PERIOD = 0; // slowest
int TASK_3_PERIOD = 0; // adapative

int TASK_1_IDX = 0;

int task_config[TASK_NUMBERS][5] = {
{0, 1, 1, 0, 0}
};
/*
int task_config[TASK_NUMBERS][5] = {
{0, 1, 1, 0, 0},
{1, 1, 12, 0, 0},
{2, 2, 12, 0, 0},
{3, 2, 15, 0, 0},
{4, 2, 20, 0, 0},
{5, 1, 10, 0, 0},
{6, 1, 100, 0, 0}
};
*/

void task_init(void) {

    for (int i = 0; i < TASK_NUMBERS; i++) {
        class Task t1(task_config[i][0], task_config[i][1], task_config[i][2],
                    task_config[i][3], task_config[i][4]);
        afbs_create_task(t1, NULL, NULL, NULL);
    }

    /* override some tasks for control tasks */
    TASK_1_PERIOD = afbs_get_param(0) / KERNEL_TICK_TIME;
    TASK_2_PERIOD = afbs_get_param(1) / KERNEL_TICK_TIME;
    TASK_3_PERIOD = afbs_get_param(2) / KERNEL_TICK_TIME;

    class Task tau1(TASK_1_IDX, 1, TASK_1_PERIOD, 0, 0);
    //class Task tau2(7, 20, TASK_2_PERIOD, 0, 0);
    //class Task tau3(8, 20, TASK_3_PERIOD, 0, 0);
    afbs_create_task(tau1, NULL, task_1_start_hook, task_1_finish_hook);
    //afbs_create_task(tau2, NULL, task_2_start_hook, task_2_finish_hook);
    //afbs_create_task(tau3, NULL, task_3_start_hook, task_3_finish_hook);

    mexPrintf("t_stamp, tss, j_cost \r");

    return;
}


/*-- control tasks -----------------------------------------------------------*/
double ref;
double y;
long task1_start_cnt;

void task_1_start_hook(void) {
    ref = afbs_state_ref_load(0);
    y = afbs_state_in_load(0);

    double N = 0.1005;
    double K = 0.0499;
    double C = 100;

    double x = y / C;
    double u = -1 * K * x + N * ref;
    afbs_state_out_set(0, u);

    task1_start_cnt = afbs_get_kernel_cnt();

    return;
}

void task_1_finish_hook(void) {
    /*
    double N = 0.1005;
    double K = 0.0499;
    double C = 100;

    double x = y / C;
    double u = -1 * K * x + N * ref;
    afbs_state_out_set(0, u);

     */
     //mexPrintf("%ld \r", afbs_get_kernel_cnt() - task1_start_cnt);

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
