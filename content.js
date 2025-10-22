// Mermaid Markdown Renderer for Confluence
// This content script detects Mermaid code blocks and renders them

(function() {
  'use strict';

  // Load Mermaid library from CDN
  function loadMermaid() {
    return new Promise((resolve, reject) => {
      // Check if already loaded
      if (window.mermaid) {
        resolve(window.mermaid);
        return;
      }

      // Create script element
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js';
      script.type = 'text/javascript';

      script.onload = () => {
        // Initialize Mermaid with custom config
        if (window.mermaid) {
          window.mermaid.initialize({
            startOnLoad: false,
            theme: 'default',
            securityLevel: 'loose',
            fontFamily: 'ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", Ubuntu, "Helvetica Neue", sans-serif'
          });
          resolve(window.mermaid);
        } else {
          reject(new Error('Mermaid library loaded but not available'));
        }
      };

      script.onerror = () => reject(new Error('Failed to load Mermaid library from CDN'));

      // Append to document
      document.head.appendChild(script);
    });
  }

  // Check if text is Mermaid syntax
  function isMermaidSyntax(text) {
    const mermaidKeywords = [
      'graph ',
      'flowchart ',
      'sequenceDiagram',
      'classDiagram',
      'stateDiagram',
      'erDiagram',
      'journey',
      'gantt',
      'pie',
      'gitGraph',
      'C4Context',
      'mindmap',
      'timeline',
      'quadrantChart',
      'requirementDiagram'
    ];

    const trimmed = text.trim();
    return mermaidKeywords.some(keyword => trimmed.startsWith(keyword));
  }

  // Find all code blocks that contain Mermaid syntax
  function findMermaidCodeBlocks() {
    const codeBlocks = [];

    // Look for Confluence code blocks
    const codeElements = document.querySelectorAll('code.language-text, code[class*="language-"], pre code');

    codeElements.forEach(codeEl => {
      const text = codeEl.textContent || codeEl.innerText;

      if (text && isMermaidSyntax(text)) {
        // Find the parent container (usually a div with class 'code-block')
        let container = codeEl.closest('.code-block') || codeEl.closest('pre') || codeEl.parentElement;

        if (container && !container.hasAttribute('data-mermaid-rendered')) {
          codeBlocks.push({
            container: container,
            code: text.trim(),
            originalElement: codeEl
          });
        }
      }
    });

    return codeBlocks;
  }

  // Render a single Mermaid diagram
  async function renderMermaidBlock(block, mermaid) {
    try {
      const { container, code, originalElement } = block;

      // Mark as being processed
      container.setAttribute('data-mermaid-rendered', 'processing');

      // Create a unique ID for this diagram
      const id = `mermaid-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

      // Create container for the rendered diagram
      const renderContainer = document.createElement('div');
      renderContainer.className = 'mermaid-diagram-container';
      renderContainer.style.cssText = `
        background: white;
        padding: 20px;
        border-radius: 8px;
        margin: 10px 0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        overflow-x: auto;
        position: relative;
      `;

      // Create toggle button to show/hide original code
      const toggleButton = document.createElement('button');
      toggleButton.textContent = 'Show Code';
      toggleButton.style.cssText = `
        position: absolute;
        top: 10px;
        right: 10px;
        padding: 6px 12px;
        background: #0052CC;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 12px;
        z-index: 10;
      `;
      toggleButton.onmouseover = () => toggleButton.style.background = '#0065FF';
      toggleButton.onmouseout = () => toggleButton.style.background = '#0052CC';

      // Create diagram element
      const diagramDiv = document.createElement('div');
      diagramDiv.id = id;
      diagramDiv.className = 'mermaid';
      diagramDiv.textContent = code;

      renderContainer.appendChild(toggleButton);
      renderContainer.appendChild(diagramDiv);

      // Hide original code block
      container.style.display = 'none';

      // Insert rendered diagram before the original
      container.parentNode.insertBefore(renderContainer, container);

      // Render the diagram
      await mermaid.run({
        nodes: [diagramDiv]
      });

      // Toggle functionality
      let codeVisible = false;
      toggleButton.addEventListener('click', () => {
        if (codeVisible) {
          container.style.display = 'none';
          renderContainer.style.display = 'block';
          toggleButton.textContent = 'Show Code';
        } else {
          container.style.display = 'block';
          renderContainer.style.display = 'block';
          toggleButton.textContent = 'Hide Code';
        }
        codeVisible = !codeVisible;
      });

      // Mark as successfully rendered
      container.setAttribute('data-mermaid-rendered', 'true');

      console.log(`Successfully rendered Mermaid diagram: ${id}`);

    } catch (error) {
      console.error('Error rendering Mermaid diagram:', error);
      block.container.setAttribute('data-mermaid-rendered', 'error');

      // Show error message
      const errorDiv = document.createElement('div');
      errorDiv.style.cssText = `
        background: #FFEBE6;
        border: 1px solid #FF5630;
        color: #DE350B;
        padding: 12px;
        border-radius: 4px;
        margin: 10px 0;
      `;
      errorDiv.textContent = `Error rendering Mermaid diagram: ${error.message}`;
      block.container.parentNode.insertBefore(errorDiv, block.container);
    }
  }

  // Main function to process all Mermaid blocks
  async function processMermaidBlocks() {
    try {
      console.log('Mermaid Renderer: Starting to process code blocks...');

      // Load Mermaid library
      const mermaid = await loadMermaid();
      console.log('Mermaid library loaded successfully');

      // Find all Mermaid code blocks
      const blocks = findMermaidCodeBlocks();
      console.log(`Found ${blocks.length} Mermaid code blocks`);

      if (blocks.length === 0) {
        return;
      }

      // Render each block
      for (const block of blocks) {
        await renderMermaidBlock(block, mermaid);
      }

      console.log('Mermaid Renderer: Processing complete');

    } catch (error) {
      console.error('Error processing Mermaid blocks:', error);
    }
  }

  // Run when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', processMermaidBlocks);
  } else {
    processMermaidBlocks();
  }

  // Also observe for dynamically loaded content (Confluence loads content dynamically)
  const observer = new MutationObserver((mutations) => {
    let shouldProcess = false;

    for (const mutation of mutations) {
      if (mutation.addedNodes.length > 0) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType === 1) { // Element node
            const hasCodeBlocks = node.querySelector && (
              node.querySelector('code.language-text') ||
              node.querySelector('.code-block')
            );
            if (hasCodeBlocks) {
              shouldProcess = true;
              break;
            }
          }
        }
      }
      if (shouldProcess) break;
    }

    if (shouldProcess) {
      // Debounce processing
      clearTimeout(window.mermaidProcessTimeout);
      window.mermaidProcessTimeout = setTimeout(processMermaidBlocks, 500);
    }
  });

  // Start observing
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

  console.log('Mermaid Renderer extension loaded');
})();
