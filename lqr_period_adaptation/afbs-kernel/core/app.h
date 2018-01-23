#ifndef __APP_H_
#define __APP_H_

#define TASK_NUMBERS         (4)
#define CONTROL_TASK_NUMBERS (1)

void task_1_start_hook(void);
//void task_2_start_hook(void);
//void task_3_start_hook(void);

void task_1_finish_hook(void);
//extern void task_2_finish_hook(void);
//extern void task_3_finish_hook(void);

void task_init(void);

#endif
