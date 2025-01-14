# Needs to import ROCR package for ROC curve plotting:
library(ROCR)
print_roc <- function(rf,test_y,test_X){
  prediction_for_roc_curve <- predict(rf, test_X, type="prob")
  
  classes <- levels(test_y)
  
  auc_list <- list()
  for (i in 1:length(classes)){
    
    true_values <- ifelse(test_y == classes[i], 1, 0) # Define class[i] membership
    
    pred <- prediction(prediction_for_roc_curve[,i], true_values) # Assess classifier perf for class[i]
    
    perf <- performance(pred, "tpr", "fpr")
    # abline(a=0, b=1, col="black")
    auc.perf <- performance(pred, measure = "auc") # Calc AUC and print on screen
    auc_list[[i]] <- paste("AUC value for class",classes[i],"is ",round(auc.perf@y.values[[1]],2))
    
  } # i loop ends
return(auc_list)
}



plot_roc <- function(rf, test_y, test_X){  # test_y = test$y
  
  prediction_for_roc_curve <- predict(rf, test_X, type="prob")
  
  pretty_colours <- c("#F8766D","#00BA38","#619CFF", "orange", "purple", "azure3")
  
  classes <- levels(test_y)
  
  for (i in 1:length(classes)){
    
    true_values <- ifelse(test_y == classes[i], 1, 0) # Define class[i] membership
    
    pred <- prediction(prediction_for_roc_curve[,i], true_values) # Assess classifier perf for class[i]
    
    perf <- performance(pred, "tpr", "fpr")
    if (i==1)
    {
      plot(perf, main="ROC Curve", col=pretty_colours[i]) 
    }
    else
    {
      plot(perf, main="ROC Curve", col=pretty_colours[i], add=TRUE) 
      
    }
    
    # abline(a=0, b=1, col="black")
    auc.perf <- performance(pred, measure = "auc") # Calc AUC and print on screen
    print(auc.perf@y.values)
  } # i loop ends
  
} # func ends

# test-drive
# plot_roc(rf, test$y, test[,-1])


train_test_split <- function(df0,classifn,tr_per){
  if (classifn == "clf") {df0$y = as.factor(df0$y)}
  # Partition Data
  set.seed(222)
  ind <- sample(2, nrow(df0), replace = TRUE, prob = c(tr_per, 1-tr_per))
  train <- df0[ind==1,]
  test <- df0[ind==2,]
  return(list(train,test))
}



rf_func <- function(df0, pred_data = NULL,
                    classifn=TRUE, ntree_ui=500){
  
  if (classifn == TRUE) {df0$y = as.factor(df0$y)}
  
  # Partition Data
  set.seed(222)
  ind <- sample(2, nrow(df0), replace = TRUE, prob = c(0.7, 0.3))
  train <- df0[ind==1,]
  test <- df0[ind==2,]
  
  '--- below is for RF results output tab ---'
  
  # Random Forest in R
  rf <- randomForest(y ~ ., data=train, ntree = ntree_ui, proximity=TRUE)
  print(rf) # display results in RF results tab
  
  # output on train_data in RF results tab
  p1 <- predict(rf, train)
  if (classifn == TRUE) {
    a1 = confusionMatrix(p1, train[,1])  
    a1$table # print this as html table
    print(a1)  # as raw text below the html tbl
  }
  
  # same on test data in RF results tab
  p2 <- predict(rf, test)
  if (classifn == TRUE) {
    a1 = confusionMatrix(p2, test[,1])  
    a1$table # print this as html table
    print(a1)  # as raw text below the html tbl
  }
  
  
  '--- below for RF plots tab ---'
  plot(rf) # display plot ka output. Error rate flattens out at what #trees?
  
  plot_roc(rf, test$y, test[,-1])  # ROC plot and AUC vals
  
  MDSplot(rf, train$y)  # can display in output tab. optional
  
  
  '--- Below is for *RF prediction* tab ---'
  # -- prediction on fresh data in pred_data  ---
  if (!is.null(pred_data)){
    p3 = predict(rf, pred_data) %>% data.frame()
    out_pred_df = data.frame(p3, pred_data)  # downloadable file. 
    head(out_pred_df, 10) # display 10 rows of this as HTML tbl  
  }
  
  '--- Below for *Variable Importance* Tab. ---'
  # No. of nodes for the trees
  hist(treesize(rf),
       main = "No. of Nodes for the Trees",
       col = "green")
  
  # Variable Importance to be displayed in output tab
  varImpPlot(rf,
             sort = T,
             n.var = 10,
             main = "Top 10 - Variable Importance")
  
  imp_df = data.frame(rownames(importance(rf)), importance(rf))
  a0 = sort(imp_df$MeanDecreaseGini, decreasing = TRUE, index.return=TRUE)$ix
  rownames(imp_df) = NULL
  imp_df[a0,]  # display as html table in output tab
  
  
  
} # func ends






pca_plot <- function(y,X){
  
  y = y; X = X
  
  if (is.numeric(y)){y = as.character(paste0('y_', y))}
  X_num <- X %>% dplyr::select(where(is.numeric))
  X_num <- X_num %>% select_if(~n_distinct(.) > 1)
  #a0 = apply(X, 2, function(x) {is.numeric(x)}) %>% which(.) %>% as.numeric(); a0
  a1 = princomp(X_num, cor=TRUE)$scores[,1:2]
  a2 = data.frame(y=y, x1=a1[,1], x2=a1[,2])
  
  p <- ggplot(data=a2, aes(x=x1, y=x2, colour = factor(y))) + 
    geom_point(size = 4, shape = 19, alpha = 0.6) + 
    xlab("PCA compt1") + ylab("PCA compt 2")+ ggtitle("PCA Plot")
  
  plot(p)  } # func ends

