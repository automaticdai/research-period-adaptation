#include "afbs.h"
#include "app.h"

int TASK_1_PERIOD = 200; // normal
int TASK_2_PERIOD = 300; // slowest
int TASK_3_PERIOD = 400; // adapative

void task_init(void)
{
    TASK_1_PERIOD = afbs_get_param(0);

    class Task t0(0, 2, 10, 0, 0);
    class Task t1(1, 5, 30, 0, 0);
    class Task t2(2, 10, 100, 0, 0);
    class Task tau1(3, 20, TASK_1_PERIOD, 0, 0);
    //class Task tau2(4, 20, TASK_2_PERIOD, 0, 0);
    //class Task tau3(5, 20, TASK_3_PERIOD, 0, 0);

    afbs_create_task(t0, NULL, NULL, NULL);
    afbs_create_task(t1, NULL, NULL, NULL);
    afbs_create_task(t2, NULL, NULL, NULL);
    afbs_create_task(tau1, NULL, task_1_start_hook, task_1_finish_hook);
    //afbs_create_task(tau2, NULL, task_2_start_hook, task_2_finish_hook);
    //afbs_create_task(tau3, NULL, task_3_start_hook, task_3_finish_hook);

    return;
}

double ref;
double y;

void task_1_start_hook(void)
{
    mexPrintf("[%0.4f] Task 1 started \r", afbs_get_current_time());
    ref = afbs_state_ref_load(0);
    y = afbs_state_in_load(0);
    return;
}

void task_2_start_hook(void)
{
    return;
}

void task_3_start_hook(void)
{
    return;
}


void task_1_finish_hook(void)
{
    double error = ref - y;
    double u = error * 0.618;
    afbs_state_out_set(0, u);
    mexPrintf("[%0.4f] Task 1 finished \r", afbs_get_current_time());
    return;
}

void task_2_finish_hook(void)
{
    return;
}

void task_3_finish_hook(void)
{
    return;
}
