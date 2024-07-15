is.numeric(flow)

in_range(flow, 0.2, 20)

## as.logical is not accepted
((flow * 100) %% 5 < 1)
