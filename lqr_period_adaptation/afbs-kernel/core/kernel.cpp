/*  File:        kernel.cpp
 *  Description:
 *    Implmentation of the A-FBS kernel. This file serves as an interface to the
 *    Simulink s-function.
 */

#define S_FUNCTION_NAME kernel
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

/*************************************************************************/
#include "afbs.h"
#include "app.h"

#define KERNEL_TICK_TIME        (0.000001)  // 1us by default
#define AFBS_SAMPLING_PERIOD    (0.000030)

int TASK_0_PERIOD = 100; // normal
int TASK_1_PERIOD = 200; // slowest
int TASK_2_PERIOD = 300; // adapative

double alpha = 0;
float  error[TASK_NUMBERS];
int    param;

/*====================*
 * S-function methods *
 *====================*/

#define PARAM1(S) ssGetSFcnParam(S,0)
#define MDL_CHECK_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
static void mdlCheckParameters(SimStruct *S)
{
//   if (mxGetNumberOfElements(PARAM1(S)) != 1) {
//     ssSetErrorStatus(S,"Parameter to S-function must be a scalar");
//     return;
//   } else if (mxGetPr(PARAM1(S))[0] < 0) {
//     ssSetErrorStatus(S, "Parameter to S-function must be nonnegative");
//     return;
//   }
  TASK_0_PERIOD = mxGetPr(ssGetSFcnParam(S, 0))[0];
  TASK_1_PERIOD = mxGetPr(ssGetSFcnParam(S, 0))[1];
  TASK_2_PERIOD = mxGetPr(ssGetSFcnParam(S, 0))[2];
}
#endif /* MDL_CHECK_PARAMETERS */


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    /* check parameters */
    ssSetNumSFcnParams(S, 1);  /* Number of expected parameters */

    if(ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if(ssGetErrorStatus(S) != NULL) return;
    } else {
        return; /* The Simulink engine reports a mismatch error. */
    }


    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumRWork(S, 0);  /* for zoh output feeding the delay operator */
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);

    /* config inputs */
    if (!ssSetNumInputPorts(S, 2)) return;

    // reference
    ssSetInputPortWidth(S, 0, CONTROL_TASK_NUMBERS);
    ssSetInputPortSampleTime(S, 0, KERNEL_TICK_TIME);
    ssSetInputPortOffsetTime(S, 0, 0.0);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);

    // ADC
    ssSetInputPortWidth(S, 1, CONTROL_TASK_NUMBERS);
    ssSetInputPortSampleTime(S, 1, KERNEL_TICK_TIME);
    ssSetInputPortOffsetTime(S, 1, 0.0);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortRequiredContiguous(S, 1, 1);


    /* config outputs */
    if (!ssSetNumOutputPorts(S, 3)) return;

    // DAC
    ssSetOutputPortWidth(S, 0, CONTROL_TASK_NUMBERS);
    ssSetOutputPortSampleTime(S, 0, KERNEL_TICK_TIME);
    ssSetOutputPortOffsetTime(S, 0, 0.0);

    // Schedule
    ssSetOutputPortWidth(S, 1, 1);
    ssSetOutputPortSampleTime(S, 1, KERNEL_TICK_TIME);
    ssSetOutputPortOffsetTime(S, 1, 0.0);

    // Periods
    ssSetOutputPortWidth(S, 2, TASK_NUMBERS);
    ssSetOutputPortSampleTime(S, 2, KERNEL_TICK_TIME);
    ssSetOutputPortOffsetTime(S, 2, 0.0);

    ssSetNumSampleTimes(S, PORT_BASED_SAMPLE_TIMES);

    /* specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE |
                     SS_OPTION_PORT_SAMPLE_TIMES_ASSIGNED));


    /* initialize kernel */
    afbs_initilize(fps);

    /* create task list */
    class Task t0(0, 2, 10, 0, 0);
    class Task t1(1, 5, 30, 0, 0);
    class Task t2(2, 10, 100, 0, 0);
    class Task tau1(0, 20, TASK_0_PERIOD, 0, 0);
    class Task tau2(4, 20, TASK_1_PERIOD, 0, 0);
    class Task tau3(5, 20, TASK_2_PERIOD, 0, 0);

    afbs_create_task(t0, NULL, NULL, NULL);
    afbs_create_task(t1, NULL, NULL, NULL);
    afbs_create_task(t2, NULL, NULL, NULL);
    afbs_create_task(tau1, NULL, task_1_start_hook, task_1_finish_hook);
    afbs_create_task(tau2, NULL, task_2_start_hook, task_2_finish_hook);
    afbs_create_task(tau3, NULL, task_3_start_hook, task_3_finish_hook);


	/* print logs */
	mexPrintf("---------------------------------------------- \r");
	mexPrintf("| AFBS-Kernel v1.0                           | \r");
	mexPrintf("| by Xiaotian Dai                            | \r");
	mexPrintf("| RTS Group, Univerisyt of York (c) 2017     | \r");
	mexPrintf("---------------------------------------------- \r");

} /* end mdlInitializeSizes */


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Two tasks: One continuous, one with discrete sample time of 1.0.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    /* use CONTINUOUS_SAMPLE_TIME for continous systems */
    ssSetSampleTime(S, 0, KERNEL_TICK_TIME);
    ssSetOffsetTime(S, 0, 0.0);

    ssSetModelReferenceSampleTimeDefaultInheritance(S);
} /* end mdlInitializeSampleTimes */



#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ==========================================
 * Abstract:
 *    Initialize states.
 */
static void mdlInitializeConditions(SimStruct *S)
{

} /* end mdlInitializeConditions */


long cnt;
/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = xD, and update the zoh internal output.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T nOutputPorts  = ssGetNumOutputPorts(S);

    const real_T *s_ref = ssGetInputPortRealSignal(S, 0);
    const real_T *s_y   = ssGetInputPortRealSignal(S, 1);

    real_T *s_u         = ssGetOutputPortRealSignal(S, 0);
    real_T *s_schedule  = ssGetOutputPortRealSignal(S, 1);
    real_T *s_periods   = ssGetOutputPortRealSignal(S, 2);

    afbs_schedule();
    afbs_run();

    if (afbs_get_execution_time_left(afbs_get_running_task_id()) == 1) {
  		switch (afbs_get_running_task_id()) {
  	        case 3:
  	            error[0] = abs(s_ref[0] - s_y[0]);
  	            s_u[0] = 800 * (s_ref[0] - s_y[0]);
  	            break;

  	        case 4:
  	            error[1] = abs(s_ref[0] - s_y[1]);
  	            s_u[1] = 800 * (s_ref[0] - s_y[1]);
  	            break;

  	        case 5:
  	            error[2] = abs(s_ref[0] - s_y[2]);
  	            s_u[2] = 800 * (s_ref[0] - s_y[2]);
  	            break;

  	        case IDLE_TASK_IDX:
  	            break;

  	        default:
  	            ;
  		}
    }

    *s_schedule = afbs_get_running_task_id();

	//afbs_set_period(0, int(map(y[0], 0, 1.2, 400, 800)));
	//afbs_set_period(0, binary_output(abs(ref[0] - y[0]), 0.2, 400, 800));

	// afbs_dump_information();
  /*
	int period = afbs_get_task_period(0);
	cnt++;
	if ((cnt > 100) && (period < 1000)) {
		afbs_set_task_period(0, period + 10);
		cnt = 0;
	}
  */

    afbs_update();

    for (int i = 0; i < TASK_NUMBERS; i++) {
        s_periods[i] = afbs_get_task_period(i);
    }

} /* end mdlOutputs */



#define MDL_UPDATE
/* Function: mdlUpdate ======================================================
 * Abstract:
 *      xD = xC
 */
static void mdlUpdate(SimStruct *S, int_T tid)
{

} /* end mdlUpdate */



#define MDL_DERIVATIVES
/* Function: mdlDerivatives =================================================
 * Abstract:
 *      xdot = U
 */
static void mdlDerivatives(SimStruct *S)
{

} /* end mdlDerivatives */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */

}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
