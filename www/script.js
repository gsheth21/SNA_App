// Toggle a collapsible sidebar section
window.toggleSidebarSection = function(btn) {
    var $btn  = $(btn);
    var $body = $btn.next('.sidebar-section-body');
    $body.slideToggle(200);
    $btn.toggleClass('open');
};

$(document).ready(function() {
    console.log('Document ready fired');

    // ── Accessibility fixes ────────────────────────────────────────────────

    // html-has-lang: set language on the root element
    document.documentElement.setAttribute('lang', 'en');

    // landmark-one-main: give the content wrapper a main landmark role
    $('.content-wrapper').attr('role', 'main');

    // aria-prohibited-attr: remove aria-label from decorative icons
    // (Shiny's icon() sets both role="presentation" and aria-label, which is invalid)
    function fixAriaIcons() {
        document.querySelectorAll('i[role="presentation"][aria-label]').forEach(function(el) {
            el.removeAttribute('aria-label');
            el.setAttribute('aria-hidden', 'true');
        });
    }
    fixAriaIcons();

    // Re-apply icon fix after each Shiny output update
    $(document).on('shiny:value', function() {
        setTimeout(fixAriaIcons, 50);
        // Fix DataTables empty/invisible headers created by scrollX layout
        setTimeout(fixDatatableA11y, 300);
        // Fix shinydashboard collapse buttons that may appear in dynamic content
        setTimeout(fixCollapseButtons, 100);
    });

    // empty-table-header: fix DataTables layout artifacts
    function fixDatatableA11y() {
        // Row-index column headers that contain only whitespace
        $('table.dataTable thead th.sorting_disabled').each(function() {
            var $th = $(this);
            if ($th.text().trim() === '') {
                $th.text('#');
                $th.attr('aria-label', 'Row number');
            }
        });
        // 0-height cloned headers used by DataTables scrollX for layout — hide from AT
        $('table.dataTable thead th[style*="height: 0px"]').attr('aria-hidden', 'true');
        $('table.dataTable thead th[style*="height:0px"]').attr('aria-hidden', 'true');

        // scrollable-region-focusable: DataTables scrollX bodies must be keyboard accessible
        $('.dataTables_scrollBody').each(function() {
            if (!$(this).attr('tabindex')) {
                $(this).attr('tabindex', '0');
                $(this).attr('aria-label', 'Scrollable table content');
            }
        });
    }
    fixDatatableA11y();

    // button-name: shinydashboard collapse/expand buttons are icon-only with no accessible name
    function fixCollapseButtons() {
        $('.btn-box-tool[data-widget="collapse"]').each(function() {
            if (!$(this).attr('aria-label')) {
                $(this).attr('aria-label', 'Collapse/expand panel');
            }
        });
        $('.btn-box-tool[data-widget="remove"]').each(function() {
            if (!$(this).attr('aria-label')) {
                $(this).attr('aria-label', 'Remove panel');
            }
        });
    }
    fixCollapseButtons();

    // Re-apply icon fix after each Shiny output update

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