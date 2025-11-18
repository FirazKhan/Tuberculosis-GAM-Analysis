# ============================================================================
# TUBERCULOSIS (TB) DATA ANALYSIS USING GAMs - BRAZIL MICROREGIONS
# ============================================================================

# Load required libraries
library(mgcv)      # For GAM modeling
library(fields)    # For spatial analysis
library(maps)      # For mapping
library(sp)        # For spatial data
library(ggplot2)   # For plotting
library(dplyr)     # For data manipulation
library(viridis)   # For color schemes
library(reshape2)  # For melt function

# Load the data
load("datasets_project.RData")

# ============================================================================
# 1. DATA EXPLORATION AND PREPARATION
# ============================================================================

# Examine the data structure
cat("Data dimensions:", dim(TBdata), "\n")
cat("Variable names:", names(TBdata), "\n")
cat("Data summary:\n")
print(summary(TBdata))

# Check for missing values
cat("Missing values per variable:\n")
print(colSums(is.na(TBdata)))

# Create TB rate (cases per population)
TBdata$TB_rate <- TBdata$TB / TBdata$Population

# Log transform TB rate for modeling (add small constant to avoid log(0))
TBdata$log_TB_rate <- log(TBdata$TB_rate + 0.001)

# Create year factor for categorical modeling
TBdata$Year_fac <- as.factor(TBdata$Year)

# ============================================================================
# 2. INITIAL DATA VISUALIZATION
# ============================================================================

# Plot TB counts for 2014 using the provided function
plot.map(TBdata$TB[TBdata$Year==2014], n.levels=7, main="TB counts for 2014")

# Plot TB rates for 2014
plot.map(TBdata$TB_rate[TBdata$Year==2014], n.levels=7, main="TB rates for 2014")

# Distribution of TB rates
hist(TBdata$TB_rate, breaks=50, main="Distribution of TB Rates", xlab="TB Rate", col="lightblue")
abline(v=mean(TBdata$TB_rate, na.rm=TRUE), col="red", lwd=2)

# Boxplot of TB rates by year
boxplot(TB_rate ~ Year, data=TBdata, main="TB Rates by Year", ylab="TB Rate")

# ============================================================================
# 3. CORRELATION ANALYSIS OF COVARIATES
# ============================================================================

# Select socio-economic covariates
covariates <- c("Indigenous", "Illiteracy", "Urbanisation", "Density", 
                "Poverty", "Poor_Sanitation", "Unemployment", "Timeliness")

# Correlation matrix
cor_matrix <- cor(TBdata[, covariates], use="complete.obs")
print("Correlation matrix of socio-economic covariates:")
print(round(cor_matrix, 3))

# Create correlation heatmap
cor_melted <- melt(cor_matrix)

# Plot correlation heatmap
ggplot(cor_melted, aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() +
  scale_fill_gradient2(low="blue", high="red", mid="white", 
                       midpoint=0, limit=c(-1,1), name="Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size=10),
        axis.text.y = element_text(size=10),
        plot.title = element_text(hjust = 0.5, size=14, face="bold")) +
  labs(title="Correlation Matrix of Socio-economic Variables",
       x="", y="") +
  geom_text(aes(label=sprintf("%.2f", value)), size=3, color="black")

# Alternative heatmap using base R (if ggplot2 has issues)
# heatmap(cor_matrix, col=colorRampPalette(c("blue", "white", "red"))(100),
#         main="Correlation Matrix Heatmap", 
#         cexRow=0.8, cexCol=0.8, margins=c(8,8))

# ============================================================================
# 4. GAM MODELING - BASIC MODEL WITH COVARIATES
# ============================================================================

# Model 1: Basic GAM with socio-economic covariates
gam1 <- gam(log_TB_rate ~ s(Indigenous) + s(Illiteracy) + s(Urbanisation) + 
            s(Density) + s(Poverty) + s(Poor_Sanitation) + s(Unemployment) + 
            s(Timeliness) + Year_fac, 
            data=TBdata, family=gaussian())

# Model summary
cat("Model 1 Summary:\n")
print(summary(gam1))

# Model diagnostics
par(mfrow=c(2,2))
gam.check(gam1)

# ============================================================================
# 5. SPATIAL MODELING
# ============================================================================

# Model 2: Add spatial smooth using longitude and latitude
gam2 <- gam(log_TB_rate ~ s(Indigenous) + s(Illiteracy) + s(Urbanisation) + 
            s(Density) + s(Poverty) + s(Poor_Sanitation) + s(Unemployment) + 
            s(Timeliness) + Year_fac + s(lon, lat), 
            data=TBdata, family=gaussian())

cat("Model 2 Summary (with spatial component):\n")
print(summary(gam2))

# Compare models
cat("Model comparison:\n")
print(anova(gam1, gam2, test="Chisq"))

# ============================================================================
# 6. SPATIO-TEMPORAL MODELING
# ============================================================================

# Model 3: Add spatio-temporal interaction
gam3 <- gam(log_TB_rate ~ s(Indigenous) + s(Illiteracy) + s(Urbanisation) + 
            s(Density) + s(Poverty) + s(Poor_Sanitation) + s(Unemployment) + 
            s(Timeliness) + Year_fac + s(lon, lat) + s(lon, lat, by=Year_fac), 
            data=TBdata, family=gaussian())

cat("Model 3 Summary (with spatio-temporal interaction):\n")
print(summary(gam3))

# Model comparison
cat("Model comparison (2 vs 3):\n")
print(anova(gam2, gam3, test="Chisq"))

# ============================================================================
# 7. MODEL SELECTION AND DIAGNOSTICS
# ============================================================================

# AIC comparison
aic_values <- c(AIC(gam1), AIC(gam2), AIC(gam3))
cat("AIC values:\n")
cat("Model 1 (covariates only):", aic_values[1], "\n")
cat("Model 2 (with spatial):", aic_values[2], "\n")
cat("Model 3 (with spatio-temporal):", aic_values[3], "\n")

# Select best model based on AIC
best_model <- ifelse(which.min(aic_values) == 1, "gam1", 
                    ifelse(which.min(aic_values) == 2, "gam2", "gam3"))
cat("Best model based on AIC:", best_model, "\n")

# ============================================================================
# 8. RESULTS VISUALIZATION
# ============================================================================

# Plot smooth effects for the best model
if(best_model == "gam1") {
  plot(gam1, pages=1, residuals=TRUE, pch=19, cex=0.5)
} else if(best_model == "gam2") {
  plot(gam2, pages=1, residuals=TRUE, pch=19, cex=0.5)
} else {
  plot(gam3, pages=1, residuals=TRUE, pch=19, cex=0.5)
}

# Spatial effects visualization
if(best_model != "gam1") {
  # Get spatial predictions
  pred_data <- expand.grid(
    lon = seq(min(TBdata$lon), max(TBdata$lon), length.out=50),
    lat = seq(min(TBdata$lat), max(TBdata$lat), length.out=50),
    Indigenous = mean(TBdata$Indigenous),
    Illiteracy = mean(TBdata$Illiteracy),
    Urbanisation = mean(TBdata$Urbanisation),
    Density = mean(TBdata$Density),
    Poverty = mean(TBdata$Poverty),
    Poor_Sanitation = mean(TBdata$Poor_Sanitation),
    Unemployment = mean(TBdata$Unemployment),
    Timeliness = mean(TBdata$Timeliness),
    Year_fac = "2013"
  )
  
  if(best_model == "gam2") {
    pred_data$pred <- predict(gam2, newdata=pred_data)
  } else {
    pred_data$pred <- predict(gam3, newdata=pred_data)
  }
  
  # Plot spatial predictions
  plot.map(pred_data$pred, n.levels=7, main="Predicted TB Risk (Spatial Component)")
}

# ============================================================================
# 9. RESOURCE ALLOCATION ANALYSIS
# ============================================================================

# Calculate residuals from the best model
if(best_model == "gam1") {
  TBdata$residuals <- residuals(gam1)
  TBdata$fitted <- fitted(gam1)
} else if(best_model == "gam2") {
  TBdata$residuals <- residuals(gam2)
  TBdata$fitted <- fitted(gam2)
} else {
  TBdata$residuals <- residuals(gam3)
  TBdata$fitted <- fitted(gam3)
}

# Identify high-risk regions (high residuals)
high_risk_threshold <- quantile(TBdata$residuals, 0.95)
high_risk_regions <- TBdata$residuals > high_risk_threshold

cat("Number of high-risk regions:", sum(high_risk_regions), "\n")
cat("High-risk threshold (95th percentile):", high_risk_threshold, "\n")

# Plot high-risk regions
plot.map(TBdata$residuals[TBdata$Year==2013], n.levels=7, 
         main="Model Residuals (2013) - High Risk Regions")

# ============================================================================
# 10. TEMPORAL ANALYSIS
# ============================================================================

# Analyze temporal trends
temporal_summary <- TBdata %>%
  group_by(Year) %>%
  summarise(
    mean_rate = mean(TB_rate, na.rm=TRUE),
    median_rate = median(TB_rate, na.rm=TRUE),
    sd_rate = sd(TB_rate, na.rm=TRUE),
    n_regions = n()
  )

cat("Temporal summary:\n")
print(temporal_summary)

# Plot temporal trends
plot(temporal_summary$Year, temporal_summary$mean_rate, 
     type="b", pch=19, main="Temporal Trend in TB Rates", 
     xlab="Year", ylab="Mean TB Rate")

# ============================================================================
# 11. CONCLUSIONS AND RECOMMENDATIONS
# ============================================================================

cat("\n=== ANALYSIS CONCLUSIONS ===\n")

# Significant covariates
if(best_model == "gam1") {
  sig_vars <- summary(gam1)$s.table[summary(gam1)$s.table[,4] < 0.05, ]
} else if(best_model == "gam2") {
  sig_vars <- summary(gam2)$s.table[summary(gam2)$s.table[,4] < 0.05, ]
} else {
  sig_vars <- summary(gam3)$s.table[summary(gam3)$s.table[,4] < 0.05, ]
}

cat("Significant socio-economic covariates (p < 0.05):\n")
if(nrow(sig_vars) > 0) {
  print(rownames(sig_vars))
} else {
  cat("No significant covariates found.\n")
}

# Spatial structure
if(best_model != "gam1") {
  cat("Spatial structure is significant in the model.\n")
} else {
  cat("No significant spatial structure detected.\n")
}

# Spatio-temporal structure
if(best_model == "gam3") {
  cat("Spatio-temporal interaction is significant.\n")
} else {
  cat("No significant spatio-temporal interaction detected.\n")
}

# Resource allocation recommendations
cat("\n=== RESOURCE ALLOCATION RECOMMENDATIONS ===\n")
cat("Focus resources on regions with high model residuals.\n")
cat("Consider socio-economic factors when allocating resources.\n")
cat("Monitor temporal trends for resource planning.\n")

# Save results
save(gam1, gam2, gam3, TBdata, file="TB_analysis_results.RData")
cat("\nAnalysis complete. Results saved to TB_analysis_results.RData\n")