data{
  // holdout datalist, modern observations 
  int<lower=0> Nhold;
  int<lower=0, upper=1> Yhold[Nhold];
  int<lower=0> nyrs;                // training data years 
  int<lower=0> nyrshold;            // years out
  int<lower=0> yidhold[Nhold];      //year out id
  int<lower=0> G;                   // Groups 
  matrix[Nhold, G] gmhold;          // group dummy variable matrix
  int<lower=0> nTreats;             // treatment groups
  matrix[Nhold, nTreats] tmhold;     // group dummy variable matrix
  int<lower=0> Wcovs;               // number of crowding effects 
  vector[Nhold] Xhold;
  matrix[Nhold,Wcovs] Whold;        // crowding matrix for holdout data
}
parameters{
  // for training data model  
  vector[nyrshold] a_raw;
  real b1_mu;
  vector[nyrshold] b1_raw;
  real<lower=0> sig_a;
  real<lower=0> sig_b1;
  vector[Wcovs] w;
  vector[nTreats] bt;
  vector[G] bg;
}
transformed parameters{
  // for training data model  
  vector[nyrshold] a;
  vector[nyrshold] b1;
  vector[Nhold] treatEff;
  real mu[Nhold];
  vector[Nhold] crowdEff;
  vector[Nhold] climEff; 
  vector[Nhold] gint;

  // for training data model -----------------------------------
  crowdEff <- Whold*w;
  treatEff <- tmhold*bt;
  gint     <- gmhold*bg;
  
  b1 <- b1_mu + sig_b1*b1_raw;
  a  <- 0 + sig_a*a_raw; 
  
  for(n in 1:Nhold){
    mu[n] <- inv_logit(gint[n] + treatEff[n] + a[yidhold[n] - nyrs] + b1[yidhold[n] - nyrs]*Xhold[n] + crowdEff[n]);
  }
  
}
model{
  // Priors
  bt ~ normal(0,10);
  bg ~ normal(0,10);
  b1_mu ~ normal(0,10);
  sig_a ~ cauchy(0,5);
  sig_b1 ~ cauchy(0,5);
  a_raw ~ normal(0,1);
  b1_raw ~ normal(0,1);
  w ~ normal(0,10);

  // Likelihood
  Yhold ~ bernoulli_log(mu);
}
