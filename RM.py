from graphviz import Digraph

dot = Digraph(comment="Sydney Music RM Diagram", format="png")

# 全局参数：正交折线 + 增加节点间距，避免交叉/穿越
dot.attr(rankdir="TB", fontsize="10", splines="ortho", nodesep="1", ranksep="1")

def make_attr_cell(attr, port, is_pk=False, is_fk=False):
    """生成带端口的属性单元格 HTML"""
    if is_pk:
        return f'<TD PORT="{port}"><U>{attr}</U></TD>'
    if is_fk:
        return f'<TD PORT="{port}"><FONT COLOR="orange"><I>{attr} (FK)</I></FONT></TD>'
    return f'<TD PORT="{port}">{attr}</TD>'

def add_table(name, attrs, color):
    """生成横向表格：左表名，右属性横排"""
    label = f"""<
    <TABLE BORDER="1" CELLBORDER="1" CELLSPACING="0">
        <TR>
            <TD BGCOLOR="{color}" ALIGN="CENTER"><B>{name}</B></TD>"""
    for attr, port, pk, fk in attrs:
        label += make_attr_cell(attr, port, pk, fk)
    label += "</TR></TABLE>>"
    dot.node(name, label=label, shape="plaintext")

# === 实体表 ===
add_table("Album", [("album_id", "album_id", True, False),
                    ("release_date", "release_date", False, False)], "lightblue")

add_table("Track", [("track_id", "track_id", True, False),
                    ("title", "title", False, False),
                    ("duration", "duration", False, False),
                    ("genre", "genre", False, False),
                    ("album_id", "album_id", False, True)], "lightblue")

add_table("Artist", [("artist_id", "artist_id", True, False),
                     ("full_name", "full_name", False, False),
                     ("email", "email", False, False)], "lightblue")

add_table("Customer", [("customer_id", "customer_id", True, False),
                       ("full_name", "full_name", False, False)], "lightblue")

add_table("Staff", [("staff_id", "staff_id", True, False),
                    ("full_name", "full_name", False, False)], "lightblue")

add_table("Review", [("review_id", "review_id", True, False),
                     ("customer_id", "customer_id", False, True),
                     ("track_id", "track_id", False, True)], "lightblue")

add_table("Playlist", [("playlist_id", "playlist_id", True, False),
                       ("customer_id", "customer_id", False, True)], "lightblue")

# === 关系表 ===
add_table("Contributed", [("artist_id", "artist_id", True, True),
                          ("track_id", "track_id", True, True)], "lightsalmon")

add_table("Remove", [("staff_id", "staff_id", True, True),
                     ("review_id", "review_id", True, True)], "lightsalmon")

add_table("PlaylistItem", [("playlist_id", "playlist_id", True, True),
                           ("track_id", "track_id", True, True)], "lightsalmon")

add_table("Listens_to", [("customer_id", "customer_id", True, True),
                         ("track_id", "track_id", True, True)], "lightsalmon")

# === 外键精确箭头（FK 下边 → PK 上边） ===
dot.edge("Track:album_id:s", "Album:album_id:n")
dot.edge("Contributed:artist_id:s", "Artist:artist_id:n")
dot.edge("Contributed:track_id:s", "Track:track_id:n")
dot.edge("Review:customer_id:s", "Customer:customer_id:n")
dot.edge("Review:track_id:s", "Track:track_id:n")
dot.edge("Remove:staff_id:s", "Staff:staff_id:n")
dot.edge("Remove:review_id:s", "Review:review_id:n")
dot.edge("Playlist:customer_id:s", "Customer:customer_id:n")
dot.edge("PlaylistItem:playlist_id:s", "Playlist:playlist_id:n")
dot.edge("PlaylistItem:track_id:s", "Track:track_id:n")
dot.edge("Listens_to:customer_id:s", "Customer:customer_id:n")
dot.edge("Listens_to:track_id:s", "Track:track_id:n")

# 输出
dot.render("sydney_music_rm", view=True)
