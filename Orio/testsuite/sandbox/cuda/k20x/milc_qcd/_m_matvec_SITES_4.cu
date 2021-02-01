__global__ void orcu_kernel35951(const int sites_on_node, double* A, double* y, double* x) {
  const int tid=blockIdx.x*blockDim.x+threadIdx.x;
  const int gsize=gridDim.x*blockDim.x;
  double ci, ai, bi, ar, br, cr;
  int j, k;
  for (int i=tid; i<=sites_on_node-1; i+=gsize) {
    {
      #pragma unroll 2
      for (j=0; j<=5; j=j+2) {
        cr=ci=0.0;
        for (k=0; k<=5; k=k+2) {
          ar=A[18*i+3*j+k];
          ai=A[18*i+3*j+k+1];
          br=x[6*i+k];
          bi=x[6*i+k+1];
          cr=cr+ar*br-ai*bi;
          ci=ci+ar*bi+ai*br;
        }
        y[6*i+j]=cr;
        y[6*i+j+1]=ci;
      }
    }
  }
}
/****************  m_matvec.c  (in su3.a) *******************************
*                                                                       *
* matrix vector multiply                                                *
*  y[i]  <-  A[i]*x[i]                                                  *
*/
void mult_su3_mat_vec(double A[], double x[], double y[]) {
  const int sites_on_node = 10; // or some other global constant value
  register int i,j,k;
  register double ar,ai,br,bi,cr,ci;

  /*@ begin PerfTuning (
        def performance_params {
          param TC[]  = range(32,1025,32);
          param BC[]  = range(14,113,14);
          param UIF[] = range(1,6);
          param PL[]  = [16,48];
          param CFLAGS[] = map(join, product(['-O0', '-O1', '-O2', '-O3']));
        }
        def input_params {
          param SITES[] = [2,4,6,8,10,12,14,16];
        }
        def input_vars {
          decl dynamic double A[18*SITES] = random;
          decl dynamic double x[6*SITES]  = random;
          decl dynamic double y[6*SITES]  = 0;
        }
        def build {
          arg build_command = 'nvcc -arch=sm_20 @CFLAGS';
        }
        def performance_counter {
          arg method = 'basic timer';
          arg repetitions = 6;
        }
        def search {
          arg algorithm = 'Exhaustive';
          arg resume = True;
          arg exhaustive_start_coord = [25, 4, 1, 1, 1]; }
  ) @*/

/**-- (Generated by Orio) 
Best performance cost: 
  [0.043583999999999998, 0.01968, 0.019071999999999999, 0.019071999999999999, 0.017503999999999999, 0.018464000000000001] 
Tuned for specific problem sizes: 
  SITES = 4 
Best performance parameters: 
  BC = 42 
  CFLAGS = -O2 
  PL = 16 
  TC = 192 
  UIF = 2 
--**/



  int sites_on_node=SITES;

  /*@ begin Loop(transform CUDA(threadCount=TC, blockCount=BC, preferL1Size=PL, unrollInner=UIF)

  for(i=0; i<=sites_on_node-1; i++) {
    for(j=0; j<=5; j+=2) {
      cr = ci = 0.0;
      for(k=0; k<=5; k+=2) {
        ar=A[18*i+3*j+k];
        ai=A[18*i+3*j+k+1];
        br=x[6*i+k];
        bi=x[6*i+k+1];
        cr += ar*br - ai*bi;
        ci += ar*bi + ai*br;
      }
      y[6*i+j]  =cr;
      y[6*i+j+1]=ci;
    }
  }

  ) @*/
  {
    cudaDeviceSynchronize();
    /*declare variables*/
    double *dev_A, *dev_y, *dev_x;
    int nthreads=192;
    /*calculate device dimensions*/
    dim3 dimGrid, dimBlock;
    dimBlock.x=nthreads;
    dimGrid.x=42;
    /*allocate device memory*/
    cudaMalloc(&dev_A,18 *SITES*sizeof(double));
    cudaMalloc(&dev_x,6 *SITES*sizeof(double));
    cudaMalloc(&dev_y,6 *SITES*sizeof(double));
    cudaDeviceSetCacheConfig(cudaFuncCachePreferShared);
    /*copy data from host to device*/
    cudaEventRecord(tstart,0);
    cudaMemcpy(dev_A,A,18 *SITES*sizeof(double),cudaMemcpyHostToDevice);
    cudaMemcpy(dev_x,x,6 *SITES*sizeof(double),cudaMemcpyHostToDevice);
    cudaEventRecord(tstop,0);
    cudaEventSynchronize(tstop);
    cudaEventElapsedTime(&orcu_transfer,tstart,tstop);
    cudaEventRecord(start,0);
    /*invoke device kernel*/
    orcu_kernel35951<<<dimGrid,dimBlock>>>(sites_on_node,dev_A,dev_y,dev_x);
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&orcu_elapsed,start,stop);
    /*copy data from device to host*/
    cudaMemcpy(y,dev_y,6 *SITES*sizeof(double),cudaMemcpyDeviceToHost);
    cudaDeviceSetCacheConfig(cudaFuncCachePreferNone);
    /*free allocated memory*/
    cudaFree(dev_A);
    cudaFree(dev_y);
    cudaFree(dev_x);
    cudaError_t err=cudaGetLastError();
    if (cudaSuccess!=err) 
      printf("CUDA runtime error: %s@",cudaGetErrorString(err));
  }
/*@ end @*/
  /*@ end @*/
}
