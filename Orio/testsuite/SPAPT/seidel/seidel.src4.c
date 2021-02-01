/*@ begin PerfTuning (          
  def build  
  {  
  arg build_command = 'gcc -O3 -fopenmp -DDYNAMIC'; 
  arg libs = '-lm -lrt';
  }
     
  def performance_counter           
  {  
    arg repetitions = 35;  
  } 
 
  def performance_params  
  { 


    # Cache tiling
    param T1_I[] = [1,16,32,64,128,256,512];
    param T1_J[] = [1,16,32,64,128,256,512];
    param T1_K[] = [1,16,32,64,128,256,512];

    param T1_Ia[] = [1,64,128,256,512,1024,2048];
    param T1_Ja[] = [1,64,128,256,512,1024,2048];
    param T1_Ka[] = [1,64,128,256,512,1024,2048];

    # Unroll-jam 
    param U_I[]  = range(1,31);
    param U_J[]  = range(1,31);
    param U_K[]  = range(1,31);

    # Register tiling
    param RT_I[] = [1,8,32];
    param RT_J[] = [1,8,32];
    param RT_K[] = [1,8,32];


    constraint tileI1 = ((T1_Ia == 1) or (T1_Ia % T1_I == 0));
    constraint tileJ1 = ((T1_Ja == 1) or (T1_Ja % T1_J == 0));
    constraint tileK1 = ((T1_Ka == 1) or (T1_Ka % T1_K == 0));

    constraint reg_capacity = (RT_I*RT_J + RT_I*RT_K + RT_J*RT_K <= 150);
    constraint unroll_limit = ((U_I == 1) or (U_J == 1) or (U_K == 1));

  } 
 
  def search  
  {
    arg algorithm = 'Randomsearch';  
    arg total_runs = 100000; 
  }

  def input_params  
  {
    param T[] = [50];
    param N[] = [500];
  } 

  def input_vars
  {
    decl static double A[N][N+17] = random;
  }

  def validation {
    arg validation_file = 'validation.c';
  }


) @*/  


#define max(x,y)    ((x) > (y)? (x) : (y))
#define min(x,y)    ((x) < (y)? (x) : (y))

int i, j, k;
int ii, jj, kk;
int iii, jjj, kkk;
int it, jt, kt;


/*@ begin Loop(
transform Composite(
    tile = [('i',T1_I,'ii'),('j',T1_J,'jj'),('k',T1_K,'kk'),
            (('ii','i'),T1_Ia,'iii'),(('jj','j'),T1_Ja,'jjj'),(('kk','k'),T1_Ka,'kkk')],
    unrolljam = (['i','j','k'],[U_I,U_J,U_K]),
    regtile = (['i','j','k'],[RT_I,RT_J,RT_K])
)
for (k=0; k<=T-1; k++)
  for (i=1; i<=N-2; i++)
    for (j=1; j<=N-2; j++)
      A[i][j] = (A[i-1][j-1] + A[i-1][j] + A[i-1][j+1]
		 + A[i][j-1] + A[i][j] + A[i][j+1]
		 + A[i+1][j-1] + A[i+1][j] + A[i+1][j+1])/9.0;
) @*/

/*@ end @*/ 
/*@ end @*/ 

