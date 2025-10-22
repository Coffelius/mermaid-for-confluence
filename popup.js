// Popup script for Mermaid Renderer extension

document.addEventListener('DOMContentLoaded', () => {
  const refreshBtn = document.getElementById('refreshBtn');
  const reloadBtn = document.getElementById('reloadBtn');
  const statusDiv = document.getElementById('status');

  function showStatus(message, isSuccess = true) {
    statusDiv.textContent = message;
    statusDiv.className = `status ${isSuccess ? 'success' : 'error'}`;
    statusDiv.style.display = 'block';

    setTimeout(() => {
      statusDiv.style.display = 'none';
    }, 3000);
  }

  refreshBtn.addEventListener('click', async () => {
    try {
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

      if (!tab.url.includes('atlassian.net')) {
        showStatus('Please navigate to an Atlassian page', false);
        return;
      }

      // Execute the content script again
      await chrome.scripting.executeScript({
        target: { tabId: tab.id },
        function: () => {
          // Reset all rendered diagrams
          document.querySelectorAll('[data-mermaid-rendered]').forEach(el => {
            el.removeAttribute('data-mermaid-rendered');
          });

          // Remove all rendered containers
          document.querySelectorAll('.mermaid-diagram-container').forEach(el => {
            el.remove();
          });

          // Show all original code blocks
          document.querySelectorAll('.code-block').forEach(el => {
            el.style.display = '';
          });

          // Trigger re-processing
          if (typeof window.mermaid !== 'undefined') {
            window.location.reload();
          }
        }
      });

      showStatus('Diagrams refreshed!', true);
    } catch (error) {
      console.error('Error refreshing diagrams:', error);
      showStatus('Error refreshing diagrams', false);
    }
  });

  reloadBtn.addEventListener('click', async () => {
    try {
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
      await chrome.tabs.reload(tab.id);
      showStatus('Page reloaded!', true);
      window.close();
    } catch (error) {
      console.error('Error reloading page:', error);
      showStatus('Error reloading page', false);
    }
  });
});
