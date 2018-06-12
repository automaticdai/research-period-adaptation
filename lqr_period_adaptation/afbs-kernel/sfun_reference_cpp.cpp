/* Copyright 2003-2014 The MathWorks, Inc. */

// *******************************************************************
// **** To build this mex function use: mex sfun_cppcount_cpp.cpp ****
// *******************************************************************

#include "sfun_reference_cpp.h"

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  sfun_reference_cpp

// Need to include simstruc.h for the definition of the SimStruct and
// its associated macro definitions.
#include "simstruc.h"

#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))

// parameters
float REF_LO = 1.01;
float REF_HI = 5.99;
float TIME_LO = 1.5;
float TIME_HI = 3.0;


// Function: mdlInitializeSizes ===============================================
// Abstract:
//    The sizes information is used by Simulink to determine the S-function
//    block's characteristics (number of inputs, outputs, states, etc.).
static void mdlInitializeSizes(SimStruct *S)
{
    // No expected parameters
    ssSetNumSFcnParams(S, 0);

    // Parameter mismatch will be reported by Simulink
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return;
    }

    // Specify I/O
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);

    ssSetNumSampleTimes(S, 1);

    // Reserve place for C++ object
    ssSetNumPWork(S, 1);

    ssSetSimStateCompliance(S, USE_CUSTOM_SIM_STATE);

    ssSetOptions(S,
                 SS_OPTION_WORKS_WITH_CODE_REUSE |
                 SS_OPTION_EXCEPTION_FREE_CODE |
                 SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME);

}


// Function: mdlInitializeSampleTimes =========================================
// Abstract:
//   This function is used to specify the sample time(s) for your
//   S-function. You must register the same number of sample times as
//   specified in ssSetNumSampleTimes.
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S); 
}

// Function: mdlStart =======================================================
// Abstract:
//   This function is called once at start of model execution. If you
//   have states that should be initialized once, this is the place
//   to do it.
#define MDL_START
static void mdlStart(SimStruct *S)
{
    // Store new C++ object in the pointers vector
    DoubleAdder *da  = new DoubleAdder();
    ssGetPWork(S)[0] = da;
}

// Function: mdlOutputs =======================================================
// Abstract:
//   In this function, you compute the outputs of your S-function
//   block.
float r3;
float time_now;
float time_target;
int ref_new;
int ref_last;

static void mdlOutputs(SimStruct *S, int_T tid)
{
    // Retrieve C++ object from the pointers vector
    DoubleAdder *da = static_cast<DoubleAdder *>(ssGetPWork(S)[0]);
    
    // Get data addresses of I/O
    InputRealPtrsType  u = ssGetInputPortRealSignalPtrs(S,0);
               real_T *y = ssGetOutputPortRealSignal(S, 0);

    time_now = *u[0];
    
    if (time_now >= time_target)
    {
        // update next target time
        float r2 = TIME_LO + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX /(TIME_HI - TIME_LO))); 
        time_target = time_now + r2;
        
        // update new reference value
        while (ref_new == ref_last)
        {
            r3 = REF_LO + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX /(REF_HI - REF_LO)));
            ref_new = (int)r3;
        }
        ref_last = ref_new;
    }
    
    //mexPrintf("%f\r", time_now);
    
    // y[0] = da->AddTo(*u[0]);
    y[0] = ref_last;
}

/* Define to indicate that this S-Function has the mdlG[S]etSimState methods */
#define MDL_SIM_STATE

/* Function: mdlGetSimState =====================================================
 * Abstract:
 *
 */
static mxArray* mdlGetSimState(SimStruct* S)
{
    // Retrieve C++ object from the pointers vector
    DoubleAdder *da = static_cast<DoubleAdder*>(ssGetPWork(S)[0]);
    return mxCreateDoubleScalar(da->GetPeak());
}
/* Function: mdlGetSimState =====================================================
 * Abstract:
 *
 */
static void mdlSetSimState(SimStruct* S, const mxArray* ma)
{
    // Retrieve C++ object from the pointers vector
    DoubleAdder *da = static_cast<DoubleAdder*>(ssGetPWork(S)[0]);
    da->SetPeak(mxGetPr(ma)[0]);
}

// Function: mdlTerminate =====================================================
// Abstract:
//   In this function, you should perform any actions that are necessary
//   at the termination of a simulation.  For example, if memory was
//   allocated in mdlStart, this is the place to free it.
static void mdlTerminate(SimStruct *S)
{
    // Retrieve and destroy C++ object
    DoubleAdder *da = static_cast<DoubleAdder *>(ssGetPWork(S)[0]);
    delete da;
}


// Required S-function trailer
#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
