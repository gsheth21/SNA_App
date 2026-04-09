// Toggle a collapsible sidebar section
window.toggleSidebarSection = function(btn) {
    var $btn  = $(btn);
    var $body = $btn.next('.sidebar-section-body');
    $body.slideToggle(200);
    $btn.toggleClass('open');
};

$(document).ready(function() {
    console.log('Document ready fired');

    $(document).on('click', '#sidebar-toggle-button', function() {
        $('.main-sidebar').toggleClass('collapsed');
        $('.main-header').toggleClass('collapsed');
        $('.content-wrapper').toggleClass('collapsed');
    });

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
});