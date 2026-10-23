library(torch)

dnn <- nn_module(
  'RecoveredHMDA_DNN',
  initialize = function (n_features) 
{
    self$network <- nn_sequential(nn_linear(n_features, 64), nn_relu(), nn_dropout(0.2), nn_linear(64, 32), nn_relu(), nn_dropout(0.1), nn_linear(32, 1))
},
  forward = function (x) 
{
    self$network(x)
}
)
