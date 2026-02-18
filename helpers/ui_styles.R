get_custom_css <- function() {
  tags$style(HTML("
    /* ============================================================
       RESET DEFAULT BEHAVIOR
       ============================================================ */
    body, html {
        height: 100vh !important;
        overflow: hidden !important;
        margin: 0 !important;
        padding: 0 !important;
    }
    
    /* ============================================================
       NC STATE THEME
       ============================================================ */
    .box { 
        border-radius: 5px; 
        margin-bottom: 20px;
    }
    .main-header .logo { 
        font-weight: bold; 
        background-color: #CC0000 !important; 
    }
    .main-header .navbar { 
        background-color: #CC0000 !important; 
    }
    .skin-red .main-sidebar { 
        background-color: #000000; 
    }
    .btn-danger {
        background-color: #CC0000 !important;
        border-color: #990000 !important;
    }
    .btn-danger:hover {
        background-color: #990000 !important;
    }
    .box.box-solid.box-danger > .box-header {
        background-color: #CC0000 !important;
    }
    
    /* ============================================================
       FIXED HEADER
       ============================================================ */
    .main-header {
        position: fixed !important;
        top: 0 !important;
        right: 0 !important;
        left: 0 !important;
        z-index: 1030 !important;
        height: 50px !important;
    }
    
    .main-header .logo {
        height: 50px !important;
        line-height: 50px !important;
    }
    
    .main-header .navbar {
        min-height: 50px !important;
        margin-left: 300px !important;
    }
    
    /* ============================================================
       FIXED SIDEBAR WITH SCROLLING
       ============================================================ */
    .main-sidebar {
        position: fixed !important;
        top: 0px !important;
        left: 0 !important;
        bottom: 0 !important;
        width: 300px !important;
        overflow-y: auto !important;
        overflow-x: hidden !important;
        z-index: 1020 !important;
    }
    
    .main-sidebar::-webkit-scrollbar {
        width: 8px;
    }
    .main-sidebar::-webkit-scrollbar-track {
        background: #000000;
    }
    .main-sidebar::-webkit-scrollbar-thumb {
        background: #CC0000;
        border-radius: 4px;
    }
    
    .sidebar {
        padding-bottom: 20px;
        padding-top: 10px;
    }
    
    /* ============================================================
       MAIN CONTENT AREA WITH SCROLLING - THIS IS THE KEY FIX
       ============================================================ */
    .content-wrapper {
        position: fixed !important;
        top: 50px !important;
        right: 0 !important;
        bottom: 0 !important;
        left: 300px !important;
        overflow-y: scroll !important;
        overflow-x: hidden !important;
        margin: 0 !important;
        padding: 0 !important;
        background-color: #f4f4f4;
        z-index: 800 !important;
    }
    
    .content-wrapper::-webkit-scrollbar {
        width: 10px;
    }
    .content-wrapper::-webkit-scrollbar-track {
        background: #e0e0e0;
    }
    .content-wrapper::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 5px;
    }

    .content {
        min-height: 0 !important;
        height: auto !important;
        padding: 15px !important;
        padding-bottom: 50px !important
    }

    /* Ensure tab containers can grow */
    .tab-content, 
    .tab-pane,
    #tab-content-wrapper {
        height: auto !important;
        min-height: 0 !important;
        overflow: visible !important;
    }

    .tab-inner {
        height: auto !important;
        padding-bottom: 50px;
    }
    
    /* ============================================================
       ENSURE VISIBILITY OF ALL CONTENT
       ============================================================ */
    .fluidRow, .row {
        overflow: visible !important;
    }
    
    .box {
        overflow: visible !important;
    }
    
    /* ============================================================
       HORIZONTAL NAVIGATION
       ============================================================ */
    #horizontal-nav {
        display: flex;
        align-items: center;
        height: 50px;
        gap: 5px;
    }
    
    #horizontal-nav .nav-link {
        display: flex;
        align-items: center;
        gap: 5px;
        padding: 8px 15px;
        color: rgba(255, 255, 255, 0.8);
        text-decoration: none;
        border-radius: 3px;
        transition: all 0.3s ease;
        font-size: 14px;
        white-space: nowrap;
        cursor: pointer;
    }
    
    #horizontal-nav .nav-link:hover {
        background-color: rgba(255, 255, 255, 0.1);
        color: #ffffff;
    }
    
    #horizontal-nav .nav-link.active {
        background-color: rgba(255, 255, 255, 0.2);
        color: #ffffff;
        font-weight: bold;
    }
    
    .navbar-custom-menu {
        float: left !important;
    }
  "))
}

get_custom_javascript <- function() {
  tags$script(HTML("
    $(document).ready(function() {
      console.log('Initializing navigation...');
      
      // Remove AdminLTE's inline styles immediately
      $('.content-wrapper').removeAttr('style');
      
      // Set overview as default active tab on load
      setTimeout(function() {
        Shiny.setInputValue('current_tab', 'overview', {priority: 'event'});
        $('#horizontal-nav .nav-link[data-tab=\"overview\"]').addClass('active');
        console.log('Default tab set to: overview');
      }, 100);
      
      // Navigation click handler
      $(document).on('click', '#horizontal-nav .nav-link', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        var tabName = $(this).data('tab');
        console.log('Tab clicked:', tabName);
        
        // Update active state
        $('#horizontal-nav .nav-link').removeClass('active');
        $(this).addClass('active');
        
        // Update Shiny input with timestamp to force change
        Shiny.setInputValue('current_tab', tabName, {priority: 'event'});
        Shiny.setInputValue('tab_click_time', new Date().getTime(), {priority: 'event'});
        
        console.log('Shiny input set to:', tabName);
        
        // Scroll to top
        $('.content-wrapper').scrollTop(0);
      });
      
      // Remove inline styles whenever Shiny updates content
      $(document).on('shiny:bound shiny:value', function() {
        $('.content-wrapper').removeAttr('style');
      });
      
      // Initialize first tab in any tabBox
      setTimeout(function() {
        $('.nav-tabs-custom .nav-tabs li:first-child a').tab('show');
      }, 500);
    });
  "))
}