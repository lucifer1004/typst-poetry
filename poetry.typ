#let poem(
    title: none, 
    author: none, 
    date: none,
    update: none,
    meta: (
        date: (
            prefix: "",
            suffix: "written",
        ),
        update: (
            prefix: "",
            suffix: "modified",
        ),
    ),
    linenumber: (left: "1:1", right: none, current: false), 
    ..parts
) = {
    set align(center)
    set par(justify: true, leading: 1em)

    heading(level: 1, title)
    v(1em)
    emph(author)
    v(1em)

    let linenumbering(lineidx, currentlineidx, pos) = {
        if type(linenumber) == "dictionary" and linenumber.at(pos) != none {
            let number = if linenumber.current {
                numbering(linenumber.at(pos), lineidx, currentlineidx)
            } else {
                numbering(linenumber.at(pos), lineidx)
            }

            if pos == "left" {
                align(right, number)
            } else {
                number
            }
        }
    }

    let partcnt = parts.pos().len()
    let contents = ()

    for (partidx, body) in parts.pos().enumerate() {
        let currentline = ()
        let parttitle = none
        if body.has("children") {
            for item in body.children {
                if "heading(body:" in repr(item) {
                    parttitle = item.body
                    break
                }
            }
        }

        if partcnt > 1 or parttitle != none {
            contents.push(none)
            contents.push({
                if partidx > 0 {
                    v(2em)
                }
                align(center, heading(level: 2)[
                    #if partcnt > 1 {
                        numbering("I", partidx + 1)
                    }
                    #parttitle
                ])
            })
            contents.push(none)
        }

        if not body.has("children") {
            continue
        }

        let lineidx = 1
        let currentlineidx = 1
        let stanzaidx = 1

        for item in body.children {
            if repr(item) == "[ ]" {
                continue
            } else if repr(item) != "linebreak()" and repr(item) != "parbreak()" and "heading(body:" not in repr(item) {
                currentline.push(item)
            }

            if repr(item) == "linebreak()" or repr(item) == "parbreak()" {
                if currentline.join() != none {
                    contents.push(linenumbering(lineidx, currentlineidx, "left"))
                    contents.push(currentline.join())
                    contents.push(linenumbering(lineidx, currentlineidx, "right"))
                }
            }

            if repr(item) == "linebreak()" {
                if currentline.join() != none {
                    lineidx += 1
                    currentlineidx += 1
                }
                currentline = ()
            }

            if repr(item) == "parbreak()" {
                if currentline.join() != none {
                    lineidx += 1
                }

                currentlineidx = 1
                stanzaidx += 1
                currentline = ()

                contents.push(none)
                contents.push(none)
                contents.push(none)
            }
        }

        if currentline.join() != none  {
            contents.push(linenumbering(lineidx, currentlineidx, "left"))
            contents.push(currentline.join())
            contents.push(linenumbering(lineidx, currentlineidx, "right"))
        }
    }

    grid(
        columns: (1fr, auto, 1fr),
        none,
        {
            set align(left)
            grid(
                columns: (auto, auto, auto),
                gutter: 1em,
                ..contents,
            )
        },
        none,
    )

    if date != none {
        align(right, [
            #meta.date.prefix
            #date
            #meta.date.suffix
        ])

        if update != none {
            align(right, [
                #meta.update.prefix
                #update
                #meta.update.suffix
            ])
        }
    }
}
