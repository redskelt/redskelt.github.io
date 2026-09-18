document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll(".page__content table").forEach(function (table) {
    if (table.parentElement.classList.contains("table-scroll")) return;
    var wrapper = document.createElement("div");
    wrapper.className = "table-scroll";
    table.parentNode.insertBefore(wrapper, table);
    wrapper.appendChild(table);
  });
});
