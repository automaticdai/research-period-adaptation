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

void Task::on_task_ready(void) {
    c_ = C_;
    d_ = D_;
    r_ = T_;
    cnt_++;
}

void Task::on_task_missed_deadline() {
    d_ = D_;
    r_ = T_;
    cnt_++;
}

void Task::on_task_start(void) {
    //mexPrintf("Task %d started \r", id_);
    if (onstart_hook_ != NULL) {
        onstart_hook_();
    }
}


void Task::on_task_finish(void) {
    //mexPrintf("Task %d finished \r", id_);
    if (onfinish_hook_ != NULL) {
        onfinish_hook_();
    }
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
