#ifndef __TASK_H_
#define __TASK_H_

using namespace std;

extern long kernel_cnt;

typedef enum {ready, running, pending, waiting, deleted} enum_task_status;

/*
char *task_status_literal[] = {
    { "ready" },
    { "running" },
    { "pending" },
    { "waiting" },
    { "deleted" }
};
*/

class Task
{
public:
    int id_;
    int C_;
    int D_;
    int T_;
    int R_;
    int c_; // computation time countdown
    int d_; // deadline countdown
    int r_; // next release countdown
    int cnt_; // release count

    enum_task_status status_;
    callback onstart_hook_;
    callback onfinish_hook_;

public:
    Task(int id = 0, int Ci = 0, int Ti = 0, int Di = 0, int Ri = 0) :
        id_(id),
        C_(Ci),
        T_(Ti),
        D_(Di),
        R_(Ri)
    {
        if (Di == 0) {
            D_ = Ti;
        }
        status_ = deleted;
        cnt_ = 0;
        onstart_hook_ = NULL;
        onfinish_hook_ = NULL;
    }

    ~Task() { ; }

    void on_task_ready(void);
    void on_task_start(void);
    void on_task_finish(void);
    void set_onstart_hook(callback onstart);
    void set_onfinish_hook(callback onfinish);
    void repr(void);
};

typedef class Task CTask;

#endif
