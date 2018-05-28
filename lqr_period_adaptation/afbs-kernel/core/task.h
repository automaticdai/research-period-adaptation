#ifndef __TASK_H_
#define __TASK_H_

#include <random>

using namespace std;

extern long kernel_cnt;

typedef enum {ready, running, pending, waiting, deleted} enum_task_status;

class Task
{
public:
    int id_;
    int C_;
    int D_;
    int T_;
    int R_;

    int C_this_;    // computation time of this release (because it is random)
    
    int c_;         // computation time countdown
    int d_;         // deadline countdown
    int r_;         // next release countdown
    int cnt_;       // release count

    int type_;      // task type: periodic, sporadic, run_once (not yet used)

    /* variables used for calc response time */
    long release_time_cnt;
    long start_time_cnt;
    long finish_time_cnt;

    /* statistics */
    int BCRT_; // task best-case response time
    int WCRT_; // task worst-case response time


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

        type_ = 0;

        release_time_cnt = 0;
        start_time_cnt = 0;
        finish_time_cnt = 0;

        BCRT_ = 100000;
        WCRT_ = 0;
    }

    ~Task() { ; }

    void on_task_ready(void);
    void on_task_start(void);
    void on_task_finish(void);
    void on_task_missed_deadline(void);
    void set_onstart_hook(callback onstart);
    void set_onfinish_hook(callback onfinish);
    void repr(void);
};

typedef class Task CTask;

#endif
