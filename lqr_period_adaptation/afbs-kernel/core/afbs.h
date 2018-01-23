#ifndef __AFBS_H_
#define __AFBS_H_

#include "mex.h"

#include "types.h"
#include "configs.h"
#include "utils.h"
#include "task.h"

/* Scheduler Kernel Variables */
#define KERNEL_TICK_TIME     (0.001000)                 // 1us by default
#define AFBS_SAMPLING_PERIOD (0.000030)
#define TASK_MAX_NUM         (6)
#define IDLE_TASK_IDX        (TASK_MAX_NUM)

#define STATES_REF_NUM       (1)
#define STATES_IN_NUM        (1)
#define STATES_OUT_NUM       (1)
#define PARAM_NUM            (1)

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

long afbs_get_kernel_cnt(void);
long afbs_get_idle_cnt(void);
float afbs_get_current_time(void);

void afbs_state_in_set(int, double);
void afbs_state_ref_set(int, double);
double afbs_state_out_load(int);

double afbs_state_in_load(int);
double afbs_state_ref_load(int);
void afbs_state_out_set(int, double);

void afbs_set_param(int, double);
double afbs_get_param(int);

#endif
