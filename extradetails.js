return {
  description: $.trim($(".extContentHighlightPib table td:last p").text()).replace(/\n\s+/g, "\n"),
  back: $(".hsbcButtonBack")[0].href
};
