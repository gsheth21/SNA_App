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
    // $(document).on('shiny:bound shiny:value', function() {
    //     $('.content-wrapper').removeAttr('style');
    // });

    $(document).on('click', '#toggle_sidebar', function() {
        $('.main-sidebar').slideToggle();
        $('.content-wrapper').toggleClass('sidebar-collapsed');
    });
    
    // Initialize first tab in any tabBox
    setTimeout(function() {
        $('.nav-tabs-custom .nav-tabs li:first-child a').tab('show');
    }, 500);
});


