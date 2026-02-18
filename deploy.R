# ======================================================
# SOCIAL NETWORK ANALYSIS APP
# Deployment Script for shinyapps.io
# ======================================================

cat("\n")
cat("====================================================\n")
cat("  SOCIAL NETWORK ANALYSIS APP DEPLOYMENT\n")
cat("====================================================\n\n")

# Step 1: Check if rsconnect is installed
cat("Step 1: Checking for rsconnect package...\n")
if (!requireNamespace("rsconnect", quietly = TRUE)) {
  cat("✗ rsconnect not found. Installing...\n")
  install.packages("rsconnect")
  cat("✓ rsconnect installed!\n\n")
} else {
  cat("✓ rsconnect already installed!\n\n")
}

library(rsconnect)

# Step 2: Check if account is configured
cat("Step 2: Checking account configuration...\n")
accounts <- rsconnect::accounts()

if (nrow(accounts) == 0) {
  cat("\n")
  cat("⚠ No account configured yet!\n\n")
  cat("SETUP INSTRUCTIONS:\n")
  cat("==================\n\n")
  cat("1. Go to https://www.shinyapps.io/ and create a FREE account\n\n")
  cat("2. After logging in, click your name (top right) → Tokens\n\n")
  cat("3. Click 'Show' next to your token, then 'Show Secret'\n\n")
  cat("4. Copy the command that looks like:\n")
  cat("   rsconnect::setAccountInfo(name='yourname', token='ABC...', secret='XYZ...')\n\n")
  cat("5. Paste and run that command in R Console\n\n")
  cat("6. Run this script again: source('deploy.R')\n\n")
  
} else {
  cat("✓ Account configured:\n")
  print(accounts[, c("name", "server")])
  cat("\n")
  
  # Step 3: Verify required packages
  cat("Step 3: Checking required packages...\n")
  required_packages <- c("shiny", "igraph", "shinydashboard", "DT", 
                         "visNetwork", "ggplot2", "plotly")
  
  missing_packages <- c()
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_packages <- c(missing_packages, pkg)
    }
  }
  
  if (length(missing_packages) > 0) {
    cat("⚠ Missing packages detected:", paste(missing_packages, collapse = ", "), "\n")
    cat("Installing missing packages...\n")
    install.packages(missing_packages)
    cat("✓ Packages installed!\n\n")
  } else {
    cat("✓ All required packages installed!\n\n")
  }
  
  # Step 4: Ready to deploy
  cat("Step 4: Ready to deploy!\n\n")
  
  # Prompt for app name
  cat("Enter a name for your app (or press Enter for 'SNA_App'):\n")
  cat("This will be part of your URL: https://yourname.shinyapps.io/APPNAME/\n")
  app_name <- readline(prompt = "App name: ")
  
  if (app_name == "") {
    app_name <- "SNA_App"
  }
  
  cat("\n")
  cat("Deploying as:", app_name, "\n")
  cat("This may take 5-10 minutes...\n")
  cat("The app includes multiple modules and datasets, so be patient!\n\n")
  
  # Deploy the app
  tryCatch({
    rsconnect::deployApp(
      appDir = getwd(),
      appName = app_name,
      appTitle = "Social Network Analysis App",
      launch.browser = TRUE,
      forceUpdate = TRUE
    )
    
    cat("\n")
    cat("====================================================\n")
    cat("  ✓ DEPLOYMENT SUCCESSFUL!\n")
    cat("====================================================\n\n")
    cat("Your app is live at:\n")
    cat("https://", accounts$name[1], ".shinyapps.io/", app_name, "/\n\n", sep = "")
    cat("Share this link with your students and collaborators!\n\n")
    cat("To manage your app:\n")
    cat("- Dashboard: https://www.shinyapps.io/admin/#/applications\n")
    cat("- View logs, restart, or delete the app\n")
    cat("- Monitor usage and performance\n\n")
    
  }, error = function(e) {
    cat("\n")
    cat("✗ Deployment failed!\n")
    cat("Error:", conditionMessage(e), "\n\n")
    cat("Common issues:\n")
    cat("- Make sure all packages are installed locally\n")
    cat("- Check your internet connection\n")
    cat("- Verify account credentials are correct\n")
    cat("- Ensure all data files are in the data/ folder\n")
    cat("- Try: rsconnect::showLogs()\n\n")
  })
}

cat("\n")
cat("====================================================\n")
cat("  FREE TIER LIMITS\n")
cat("====================================================\n")
cat("- 5 applications maximum\n")
cat("- 25 active hours per month\n")
cat("- App sleeps after 15 minutes of inactivity\n")
cat("- Wakes up automatically when accessed\n\n")
cat("Need more? Upgrade to Basic ($9/month) for 500 hours\n\n")

cat("====================================================\n")
cat("  APP FEATURES\n")
cat("====================================================\n")
cat("Your deployed app includes:\n")
cat("- Network Overview & Visualization\n")
cat("- Centrality Measures\n")
cat("- Community Detection\n")
cat("- Assortativity Analysis\n")
cat("- Roles & Positions\n")
cat("- Connectivity Metrics\n")
cat("- Network Simulations\n")
cat("- Multiple Built-in Datasets\n\n")