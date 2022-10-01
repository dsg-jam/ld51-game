(async () => {
    const response = await fetch('https://api.github.com/repos/mineiwik/LD51/contents/?ref=github-pages');
    const data = await response.json();
    let htmlString = '<ul>';

    for (let file of data) {
        if (file.type === "dir" && /^\d/.test(file.name)) {
            htmlString += `<li><a href="${file.path}">${file.name}</a></li>`;
        }
    }

    htmlString += '</ul>';
    document.getElementsByClassName('dsg-links')[0].innerHTML = htmlString;
})()