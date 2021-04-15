/* Include files */

#include "syl_detection_Bird_6_sfun.h"
#include "c1_syl_detection_Bird_6.h"
#include "c2_syl_detection_Bird_6.h"
#include "c5_syl_detection_Bird_6.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
uint32_T _syl_detection_Bird_6MachineNumber_;
real_T _sfTime_;

/* Function Declarations */

/* Function Definitions */
void syl_detection_Bird_6_initializer(void)
{
}

void syl_detection_Bird_6_terminator(void)
{
}

/* SFunction Glue Code */
unsigned int sf_syl_detection_Bird_6_method_dispatcher(SimStruct *simstructPtr,
  unsigned int chartFileNumber, const char* specsCksum, int_T method, void *data)
{
  if (chartFileNumber==1) {
    c1_syl_detection_Bird_6_method_dispatcher(simstructPtr, method, data);
    return 1;
  }

  if (chartFileNumber==2) {
    c2_syl_detection_Bird_6_method_dispatcher(simstructPtr, method, data);
    return 1;
  }

  if (chartFileNumber==5) {
    c5_syl_detection_Bird_6_method_dispatcher(simstructPtr, method, data);
    return 1;
  }

  return 0;
}

unsigned int sf_syl_detection_Bird_6_process_check_sum_call( int nlhs, mxArray *
  plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[20];
  if (nrhs<1 || !mxIsChar(prhs[0]) )
    return 0;

  /* Possible call to get the checksum */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"sf_get_check_sum"))
    return 0;
  plhs[0] = mxCreateDoubleMatrix( 1,4,mxREAL);
  if (nrhs>1 && mxIsChar(prhs[1])) {
    mxGetString(prhs[1], commandName,sizeof(commandName)/sizeof(char));
    commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
    if (!strcmp(commandName,"machine")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(2895058959U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(402339932U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2656883874U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(97097333U);
    } else if (!strcmp(commandName,"exportedFcn")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(0U);
    } else if (!strcmp(commandName,"makefile")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(3427571401U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3141478819U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(1950213389U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(2616696353U);
    } else if (nrhs==3 && !strcmp(commandName,"chart")) {
      unsigned int chartFileNumber;
      chartFileNumber = (unsigned int)mxGetScalar(prhs[2]);
      switch (chartFileNumber) {
       case 1:
        {
          extern void sf_c1_syl_detection_Bird_6_get_check_sum(mxArray *plhs[]);
          sf_c1_syl_detection_Bird_6_get_check_sum(plhs);
          break;
        }

       case 2:
        {
          extern void sf_c2_syl_detection_Bird_6_get_check_sum(mxArray *plhs[]);
          sf_c2_syl_detection_Bird_6_get_check_sum(plhs);
          break;
        }

       case 5:
        {
          extern void sf_c5_syl_detection_Bird_6_get_check_sum(mxArray *plhs[]);
          sf_c5_syl_detection_Bird_6_get_check_sum(plhs);
          break;
        }

       default:
        ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(0.0);
      }
    } else if (!strcmp(commandName,"target")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(3564696471U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(678668628U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(1090454852U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(3896867807U);
    } else {
      return 0;
    }
  } else {
    ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(2615672137U);
    ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3095186382U);
    ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(57003646U);
    ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(1683302877U);
  }

  return 1;

#else

  return 0;

#endif

}

unsigned int sf_syl_detection_Bird_6_autoinheritance_info( int nlhs, mxArray *
  plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[32];
  char aiChksum[64];
  if (nrhs<3 || !mxIsChar(prhs[0]) )
    return 0;

  /* Possible call to get the autoinheritance_info */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"get_autoinheritance_info"))
    return 0;
  mxGetString(prhs[2], aiChksum,sizeof(aiChksum)/sizeof(char));
  aiChksum[(sizeof(aiChksum)/sizeof(char)-1)] = '\0';

  {
    unsigned int chartFileNumber;
    chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);
    switch (chartFileNumber) {
     case 1:
      {
        if (strcmp(aiChksum, "rhavtYj4VtD0Qs0m3xXhUB") == 0) {
          extern mxArray *sf_c1_syl_detection_Bird_6_get_autoinheritance_info
            (void);
          plhs[0] = sf_c1_syl_detection_Bird_6_get_autoinheritance_info();
          break;
        }

        plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
        break;
      }

     case 2:
      {
        if (strcmp(aiChksum, "4uJExjTXBfiUnTHScpDGUH") == 0) {
          extern mxArray *sf_c2_syl_detection_Bird_6_get_autoinheritance_info
            (void);
          plhs[0] = sf_c2_syl_detection_Bird_6_get_autoinheritance_info();
          break;
        }

        plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
        break;
      }

     case 5:
      {
        if (strcmp(aiChksum, "7GARl2vwEkRLDBkuDK2RTF") == 0) {
          extern mxArray *sf_c5_syl_detection_Bird_6_get_autoinheritance_info
            (void);
          plhs[0] = sf_c5_syl_detection_Bird_6_get_autoinheritance_info();
          break;
        }

        plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
        break;
      }

     default:
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  }

  return 1;

#else

  return 0;

#endif

}

unsigned int sf_syl_detection_Bird_6_get_eml_resolved_functions_info( int nlhs,
  mxArray * plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[64];
  if (nrhs<2 || !mxIsChar(prhs[0]))
    return 0;

  /* Possible call to get the get_eml_resolved_functions_info */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"get_eml_resolved_functions_info"))
    return 0;

  {
    unsigned int chartFileNumber;
    chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);
    switch (chartFileNumber) {
     case 1:
      {
        extern const mxArray
          *sf_c1_syl_detection_Bird_6_get_eml_resolved_functions_info(void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c1_syl_detection_Bird_6_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     case 2:
      {
        extern const mxArray
          *sf_c2_syl_detection_Bird_6_get_eml_resolved_functions_info(void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c2_syl_detection_Bird_6_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     case 5:
      {
        extern const mxArray
          *sf_c5_syl_detection_Bird_6_get_eml_resolved_functions_info(void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c5_syl_detection_Bird_6_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     default:
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  }

  return 1;

#else

  return 0;

#endif

}

void syl_detection_Bird_6_debug_initialize(void)
{
  _syl_detection_Bird_6MachineNumber_ = sf_debug_initialize_machine(
    "syl_detection_Bird_6","sfun",0,3,0,0,0);
  sf_debug_set_machine_event_thresholds(_syl_detection_Bird_6MachineNumber_,0,0);
  sf_debug_set_machine_data_thresholds(_syl_detection_Bird_6MachineNumber_,0);
}

void syl_detection_Bird_6_register_exported_symbols(SimStruct* S)
{
}

static mxArray* sRtwOptimizationInfoStruct= NULL;
mxArray* load_syl_detection_Bird_6_optimization_info(void)
{
  if (sRtwOptimizationInfoStruct==NULL) {
    sRtwOptimizationInfoStruct = sf_load_rtw_optimization_info(
      "syl_detection_Bird_6", "syl_detection_Bird_6");
    mexMakeArrayPersistent(sRtwOptimizationInfoStruct);
  }

  return(sRtwOptimizationInfoStruct);
}

void unload_syl_detection_Bird_6_optimization_info(void)
{
  if (sRtwOptimizationInfoStruct!=NULL) {
    mxDestroyArray(sRtwOptimizationInfoStruct);
    sRtwOptimizationInfoStruct = NULL;
  }
}
