document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('openBrave').addEventListener('click', function() {
        fetch(browser.runtime.getURL("config.json"))
            .then(response => response.json())
            .then(config => {
                const customHandlerName = config.customHandlerName;

                browser.tabs.query({ active: true, currentWindow: true }).then((tabs) => {
                    if (tabs.length > 0) {
                        const activeTab = tabs[0];
                        console.log(`Active Tab URL: ${activeTab.url}`);

                        const url = encodeURIComponent(activeTab.url);
                        const braveUrl = `${customHandlerName}:${url}`;
                        console.log(`Encoded Brave URL: ${braveUrl}`);

                        // Open the new tab with the custom protocol URL
                        browser.tabs.create({ url: braveUrl }).then((newTab) => {
                            // Close the newly created tab
                            // browser.tabs.remove(newTab.id);
                        });
                    } else {
                        console.error("No active tab found.");
                    }
                });
            })
            .catch(error => console.error("Failed to load config:", error));
    });
});
