
correlated_RemoveToLimit <- function(data,unitPvalues,limit=0,thr=0.975,maxLoops=50,minCorr=0.50)
{
  if ((limit >= 0) && (thr < 1.0))
  {
    ntest <- 0;
    cthr <- thr;
    if (limit > 0)
    {
      slimit <- limit;
      if (limit <= 1)
      {
        slimit <- as.integer(limit*nrow(data));
      }
      if (slimit < 2) 
      {
        slimit <- 2;
      }
      if (length(unitPvalues) > slimit)
      {
        cat(slimit,"\n")
        pvalmin <- min(unitPvalues)
        pvalatlimin <- unitPvalues[order(unitPvalues)][slimit]
        maxpvalue <- max(100*pvalmin,10*pvalatlimin);
        unitPvalues <- unitPvalues[unitPvalues <= maxpvalue];
        cormat <- correlated_Remove(data,names(unitPvalues),cthr)
        unitPvalues <- unitPvalues[cormat];
        cormat <- attr(cormat,"CorrMatrix");
        while ( (length(unitPvalues) > slimit) && (ntest < maxLoops) && (cthr > minCorr) )
        {
          unitPvalues <- unitPvalues[correlated_Remove(cormat,names(unitPvalues),cthr,isDataCorMatrix=TRUE)];
          ntest = ntest + 1;
          cthr = cthr*thr;
        }
        if (length(unitPvalues) > slimit)
        {
          unitPvalues <- unitPvalues[1:slimit];
        }
      }
    }
    else
    {
      unitPvalues <- unitPvalues[correlated_Remove(data,names(unitPvalues),cthr)];
    }
  }
  return (unitPvalues);
  
}
