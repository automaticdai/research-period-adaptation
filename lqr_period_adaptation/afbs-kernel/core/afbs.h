#ifndef __AFBS_H_
#define __AFBS_H_

#include "mex.h"

#include "types.h"
#include "configs.h"
#include "utils.h"
#include "task.h"

/* Scheduler Kernel Variables */
#define TASK_MAX_NUM         (6)
#define IDLE_TASK_IDX        (TASK_MAX_NUM)

typedef enum {fps, edf} enum_scheduling_policy;

/* Scheduler Kernel Functions */
void afbs_initilize(enum_scheduling_policy sp);

void afbs_create_task(CTask t, callback task_main, callback on_start, callback on_finish);
void afbs_delete_task(int task_id);

int  afbs_get_task_period(int task_id);
void afbs_set_task_period(int task_id, int new_period);

int  afbs_get_running_task_id(void);
int  afbs_get_execution_time_left(int task_id);

void afbs_create_job(CTask j, int prio, callback job_main, callback on_start, callback on_finish);
void afbs_delete_job(int job_id);

void afbs_update(void);
void afbs_schedule(void);
void afbs_run(void);
void afbs_idle(void);
void afbs_dump_information(void);

#endif
