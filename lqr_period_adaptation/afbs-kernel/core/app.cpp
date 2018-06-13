#include "afbs.h"
#include "app.h"

int TASK_1_PERIOD = 0; // normal
int TASK_2_PERIOD = 0; // slowest
int TASK_3_PERIOD = 0; // adapative

int TASK_1_IDX = 5;

int task_config[TASK_NUMBERS][5] = {
{0,   42,   157, 0, 0},
{1,   10,   215, 0, 0},
{2,   53,   499, 0, 0},
{3,   87,   777, 0, 0},
{4,   48,   801, 0, 0},
{5,  100,  1000, 0, 0},
};

void app_init(void) {
    /* read parameters */
    TASK_1_PERIOD = afbs_get_param(0) / KERNEL_TICK_TIME;
    TASK_2_PERIOD = afbs_get_param(1) / KERNEL_TICK_TIME;
    TASK_3_PERIOD = afbs_get_param(2) / KERNEL_TICK_TIME;

    /* initialize task list */
    for (int i = 0; i < TASK_NUMBERS; i++) {
        class Task ti(task_config[i][0], task_config[i][1], task_config[i][2],
                    task_config[i][3], task_config[i][4]);
        afbs_create_task(ti, NULL, NULL, NULL);
    }

    /* override some tasks for control tasks */
    class Task tau1(TASK_1_IDX, 100, TASK_1_PERIOD, 0, 0);
    //class Task tau2(7, 20, TASK_2_PERIOD, 0, 0);
    //class Task tau3(8, 20, TASK_3_PERIOD, 0, 0);
    afbs_create_task(tau1, NULL, task_1_start_hook, task_1_finish_hook);
    //afbs_create_task(tau2, NULL, task_2_start_hook, task_2_finish_hook);
    //afbs_create_task(tau3, NULL, task_3_start_hook, task_3_finish_hook);

    return;
}


/*-- control tasks -----------------------------------------------------------*/
double ref;
double x1;
double x2;

void task_1_start_hook(void) {
    /* sample inputs */
    ref = afbs_state_ref_load(0);
    x1 = afbs_state_in_load(0);
    x2 = afbs_state_in_load(1);

    return;
}

void task_1_finish_hook(void) {
    /* LQR parameters */
    double N = 8.4334;
    double K[] = {15.4280, 31.1736};

    /* Calculate Outputs */
    double u = N * ref - (K[0] * x1 + K[1] * x2);

    /* Send output to Simulink */
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
