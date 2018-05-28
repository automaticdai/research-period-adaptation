# Metadata
## dataset_a
- no noise
- $ c_i = C_i $



### System model (stable)

- `zpk([], [-10 + 10j, -10 - 10j], 100)`

### Taskset (task number = 5, total utilization 0.6873)

```c
int task_config[TASK_NUMBERS][5] = {
{0,   70,   120, 0, 0},
{1,   80,  1210, 0, 0},
{2,   20,  2030, 0, 0},
{3,   20,  1520, 0, 0},
{4,   30,  2020, 0, 0},
{5,  100,  1000, 0, 0},
};
```

### Folder Structure

- \afbs_log
- \afbs_pi
- \afbs_ri
- \mc_pi_uniform
- \mc_pi_ecdf


## dataset_b
- bandwidth limited noise: 1e-6, sampling time: 0.01
- $ c_i = \mathcal{N}((C_i - C_i/2) / 2, (C_i - C_i/2) / 3 ) $
- reference is random generated: value range [1, 5], time interval [1.0, 2.0]

### System model:
- `zpk([], [-10 + 10j, -10 - 10j], 100)`


### Taskset (UUnifast, task number = 5, total utilization 0.6921):
```c
int task_config[TASK_NUMBERS][5] = {
{0,   42,   157, 0, 0},
{1,   10,   215, 0, 0},
{2,   53,   499, 0, 0},
{3,   87,   777, 0, 0},
{4,   48,   801, 0, 0},
{5,  100,  1000, 0, 0},
};
```

