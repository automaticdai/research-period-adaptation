#ifndef __APP_H_
#define __APP_H_

#define TASK_NUMBERS           (6)
#define CONTROL_TASK_NUMBERS   (1)
#define CONTROL_INPUT_NUMBERS  (2)
#define CONTROL_OUTPUT_NUMBERS (1)

void app_init(void);

void afbs_start_hook(void);

void task_1_start_hook(void);
void task_1_finish_hook(void);

void task_2_start_hook(void);
void task_2_finish_hook(void);

void task_3_start_hook(void);
void task_3_finish_hook(void);

#endif
