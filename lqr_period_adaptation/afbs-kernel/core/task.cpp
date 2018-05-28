#include <stddef.h>
#include "simstruc.h"

#include "types.h"
#include "task.h"

char *task_status_literal[] = {
    { "ready" },
    { "running" },
    { "pending" },
    { "waiting" },
    { "deleted" }
};

std::default_random_engine generator;

void Task::on_task_ready(void) {

    /* generate random task execution time */
    int max = C_;
    int min = C_ / 2;

    float mu = (max - min) / 2.0 + min;
    float sigma = (max - min) / 6.0;
    std::normal_distribution<double> distribution(mu, sigma);

    double number = distribution(generator);
    if (number > max) {c_ = max;}
    else if (number < min) {c_ = min;}
    else {c_ = (int)number;}
    /* end */

    C_this_ = c_;

    d_ = D_;
    r_ = T_;
    cnt_++;

    release_time_cnt = kernel_cnt;

}

void Task::on_task_start(void) {
    //mexPrintf("Task %d started \r", id_);

    start_time_cnt = kernel_cnt;

    if (onstart_hook_ != NULL) {
        onstart_hook_();
    }

}

void Task::on_task_finish(void) {
    //mexPrintf("Task %d finished \r", id_);

    finish_time_cnt = kernel_cnt;

    /* record BCRT and WCRT */
    int response_time = finish_time_cnt - release_time_cnt;

    if (response_time > WCRT_) {
        WCRT_ = response_time;
    }

    if (response_time < BCRT_) {
        BCRT_ = response_time;
    }

    if (onfinish_hook_ != NULL) {
        onfinish_hook_();
    }
}

void Task::on_task_missed_deadline() {
    d_ = D_;
    r_ = T_;
    cnt_++;
}

void Task::set_onstart_hook(callback onstart)
{
    onstart_hook_ = onstart;
}

void Task::set_onfinish_hook(callback onfinish)
{
    onfinish_hook_ = onfinish;
}

void Task::repr()
{
    mexPrintf("%d: %s | %d | %d | %d \r", id_,  task_status_literal[status_], c_, d_, r_);
}
