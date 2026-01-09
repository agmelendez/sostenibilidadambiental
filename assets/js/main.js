// IDAC - Main JavaScript File
// Security: Strict mode enabled
'use strict';

// Prevent clickjacking attacks
if (window.top !== window.self) {
    window.top.location = window.self.location;
}

/**
 * Sanitize HTML to prevent XSS attacks
 * @param {string} str - String to sanitize
 * @returns {string} Sanitized string
 */
function sanitizeHTML(str) {
    const temp = document.createElement('div');
    temp.textContent = str;
    return temp.innerHTML;
}

/**
 * Switch between main tabs
 * @param {string} tabName - Name of the tab to activate
 */
function switchTab(tabName) {
    // Validate input
    const validTabs = ['proyecto', 'resultados', 'validacion', 'metodologia', 'recomendaciones', 'descargas'];
    if (!validTabs.includes(tabName)) {
        console.error('Invalid tab name');
        return;
    }

    // Hide all tab contents
    const contents = document.querySelectorAll('.tab-content');
    contents.forEach(content => {
        content.classList.remove('active');
    });

    // Deactivate all tab buttons
    const buttons = document.querySelectorAll('.tab-button');
    buttons.forEach(button => {
        button.classList.remove('active');
    });

    // Show selected tab
    const targetTab = document.getElementById(tabName);
    if (targetTab) {
        targetTab.classList.add('active');
    }

    // Activate selected button
    const activeButton = Array.from(buttons).find(btn =>
        btn.textContent.toLowerCase().includes(tabName) ||
        btn.getAttribute('onclick')?.includes(tabName)
    );
    if (activeButton) {
        activeButton.classList.add('active');
    }

    // Update URL hash without triggering page scroll
    if (history.pushState) {
        history.pushState(null, null, '#' + tabName);
    }

    // Scroll to top smoothly
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

/**
 * Switch between sub-tabs
 * @param {string} subTabName - Name of the sub-tab to activate
 * @param {HTMLElement} element - Button element that was clicked
 */
function switchSubTab(subTabName, element) {
    // Validate input
    const validSubTabs = ['indicadores-tab', 'provincias-tab', 'cantones-tab'];
    if (!validSubTabs.includes(subTabName)) {
        console.error('Invalid sub-tab name');
        return;
    }

    // Hide all sub-tab contents
    const subContents = document.querySelectorAll('.sub-tab-content');
    subContents.forEach(content => {
        content.classList.remove('active');
    });

    // Deactivate all sub-tab buttons
    const subButtons = document.querySelectorAll('.sub-tab-button');
    subButtons.forEach(button => {
        button.classList.remove('active');
    });

    // Show selected sub-tab
    const targetSubTab = document.getElementById(subTabName);
    if (targetSubTab) {
        targetSubTab.classList.add('active');
    }

    // Activate selected button
    if (element) {
        element.classList.add('active');
    }
}

/**
 * Handle download button clicks with validation
 * @param {string} filePath - Path to the file to download
 */
function handleDownload(filePath) {
    // Validate file path to prevent directory traversal
    if (filePath.includes('..') || filePath.includes('~')) {
        console.error('Invalid file path');
        return;
    }

    // Log download for analytics (could be sent to server)
    console.log('Download initiated:', filePath);

    // The actual download is handled by the browser via the href attribute
}

/**
 * Initialize the application
 */
function initApp() {
    // Check for hash in URL and activate corresponding tab
    const hash = window.location.hash.substring(1);
    if (hash) {
        const validTabs = ['proyecto', 'resultados', 'validacion', 'metodologia', 'recomendaciones', 'descargas'];
        if (validTabs.includes(hash)) {
            switchTab(hash);
        }
    }

    // Add keyboard navigation
    document.addEventListener('keydown', function(e) {
        // Press Escape to close any modal (future implementation)
        if (e.key === 'Escape') {
            // Close modals if any
        }
    });

    // Add print styles handler
    window.addEventListener('beforeprint', function() {
        // Expand all sections before printing
        document.querySelectorAll('.tab-content').forEach(tab => {
            tab.style.display = 'block';
        });
    });

    window.addEventListener('afterprint', function() {
        // Restore original state after printing
        document.querySelectorAll('.tab-content').forEach((tab, index) => {
            if (!tab.classList.contains('active')) {
                tab.style.display = 'none';
            }
        });
    });

    // Add smooth scroll to all internal links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    console.log('IDAC Application initialized successfully');
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initApp);
} else {
    initApp();
}

// Expose functions to global scope for inline event handlers
// (Will be replaced with event listeners in future versions)
window.switchTab = switchTab;
window.switchSubTab = switchSubTab;
window.handleDownload = handleDownload;
