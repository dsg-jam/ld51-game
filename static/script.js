(async () => {
    const response = await fetch('https://api.github.com/repos/mineiwik/LD51/contents/?ref=github-pages');
    const data = await response.json();
    let htmlString = '';

    for (let file of data) {
        if (file.type === "dir" && /^\d/.test(file.name)) {
            htmlString += `<span><a href="${file.path}">${file.name}</a></span><br/>`;
        }
    }
    document.getElementsByClassName('dsg-links')[0].innerHTML = htmlString;
})()