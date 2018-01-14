#include <sys/types.h> 
#include <sys/wait.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[]){

    int status;
    pid_t parent = getpid();
    pid_t pid = fork();
    char *_argv[] = {"/home/son/workspace/cloudsuite//exp_cloudsuit.sh","-p","data_analytics","-h","thp","-f","probe_v1",NULL};

    if (pid == -1){
        printf("error\n");
    } 
    else if (pid > 0)
    {
        printf("parent pid : %d\n",pid);
        waitpid(pid, &status, 0);
    }
    else 
    {
        printf("child pid : %d\n",pid);
//        execve(_argv[0],_argv,NULL);        
        execve(_argv[0],_argv,NULL);        

    }
}
