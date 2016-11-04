data{
  // training datalist, historical observations 
  int<lower=0> N;             // observations
  vector[N] Y;  // observation vector
  vector[N] X;                // size vector
}
parameters{
  // for training data model  
  real<lower=0> sigma; 
  real b1;
  real a; 
}
transformed parameters{
// for training data model  
  vector[N] gint; 
  real mu[N];
  vector[N] crowdEff;

  // for training data model -----------------------------------

  for(n in 1:N){
    mu[n] <- a + b1*X[n];
  }
  
}
model{
   // for training data model 
  // Priors
  sigma ~ cauchy(0, 5);
  a ~ normal(0,10);
  b1 ~ normal(0,10);
  
  // Likelihood
  Y ~ normal(mu, sigma);
  
}
generated quantities {
  // hold out predictions 
  vector[N] log_lik;          // vector for computing log pointwise predictive density  
  vector[N] y_hat; 
  
  for(n in 1:N){
      log_lik[n] <- normal_log(Y[n], mu[n], sigma);
      y_hat [n]  <- normal_rng(mu[n], sigma);
  }
}

