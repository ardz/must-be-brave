fetch(browser.runtime.getURL("config.json"))
    .then(response => response.json())
    .then(config => {
        const customHandlerName = config.customHandlerName;
        console.log(`Custom Handler Name: ${customHandlerName}`);
    })
    .catch(error => console.error("Failed to load config:", error));