#ifndef __CONTROLLER_H_
#define __CONTROLLER_H_

/* PID Controller implmentation */
class PID_Controller {
    double Kp;
    double Ki;
    double Kd;
    double dt;              // sampling time
    double ref;
    double err_p;

    PID_Controller(double Kp_, double Ki_, double Kd_, double dt_) {
        this->Kp = Kp_;
        this->Ki = Ki_;
        this->Kd = Kd_;
        this->dt = dt_;
        ref = 1;
        err_p = 0;
    }

    double calc_output(double y_new) {
        double error = y_new - ref;
    }

};

#endif
