/*  File:        kernel.cpp
 *  Description:
 *    Implmentation of the A-FBS kernel. This file serves as an interface to the
 *    Simulink s-function.
 */

#define S_FUNCTION_NAME kernel      /* name of the s-function */
#define S_FUNCTION_LEVEL 2

#include <math.h>
#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

/*************************************************************************/
#include "afbs.h"
#include "app.h"

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
    for (int i = 0; i < PARAM_NUM; i++) {
        afbs_set_param(i, mxGetPr(ssGetSFcnParam(S, 0))[i]);
    }
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
    ssSetInputPortWidth(S, 1, CONTROL_INPUT_NUMBERS);
    ssSetInputPortSampleTime(S, 1, KERNEL_TICK_TIME);
    ssSetInputPortOffsetTime(S, 1, 0.0);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortRequiredContiguous(S, 1, 1);


    /* config outputs */
    if (!ssSetNumOutputPorts(S, 3)) return;

    // DAC
    ssSetOutputPortWidth(S, 0, CONTROL_OUTPUT_NUMBERS);
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

    /* print logs */
    /*
 	mexPrintf("---------------------------------------------- \r");
 	mexPrintf("| AFBS-Kernel v1.0                           | \r");
 	mexPrintf("| by Xiaotian Dai                            | \r");
 	mexPrintf("| RTS Group, Univerisyt of York (c) 2017     | \r");
 	mexPrintf("---------------------------------------------- \r");
    */

    /* initialize kernel */
    afbs_initilize(fps);

    /* initialize user application */
    app_init();

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



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      y = xD, and update the zoh internal output.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int_T nInputPorts  = ssGetNumInputPorts(S);
    const real_T *s_ref = ssGetInputPortRealSignal(S, 0);
    const real_T *s_x   = ssGetInputPortRealSignal(S, 1);

    int_T nOutputPorts  = ssGetNumOutputPorts(S);
    real_T *s_u         = ssGetOutputPortRealSignal(S, 0);
    real_T *s_schedule  = ssGetOutputPortRealSignal(S, 1);
    real_T *s_periods   = ssGetOutputPortRealSignal(S, 2);

    /* pass s_ref and s_y to application tasks */
    /* tasks also have their own 'beliefs' of the system states */
    for (int i = 0; i < ssGetInputPortWidth(S, 0); i++) {
        afbs_state_ref_set(i, s_ref[i]);
    }

    for (int i = 0; i < ssGetInputPortWidth(S, 1); i++) {
        afbs_state_in_set(i, s_x[i]);
    }

    /* select a task to run */
    afbs_schedule();

    /* run the selected task */
    afbs_run();

    /* the kernel needs to collect the output from tasks */
    for (int i = 0; i < STATES_OUT_NUM; i++) {
        s_u[i] = afbs_state_out_load(i);
    }

    s_schedule[0] = (double)afbs_get_running_task_id();

    afbs_update();

    /* record periods */
    for (int i = 0; i < ssGetOutputPortWidth(S, 2); i++) {
        s_periods[i] = afbs_get_task_period(i) * KERNEL_TICK_TIME;
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
