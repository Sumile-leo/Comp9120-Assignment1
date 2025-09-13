from graphviz import Digraph

dot = Digraph(comment="Sydney Music RM Compact", format="svg")
dot.engine = 'dot'  # 层级布局，更紧凑
dot.attr(splines="ortho", nodesep="0.4", ranksep="0.6", fontsize="10")

def make_attr_cell(text, port, is_pk=False, is_fk=False):
    if is_pk and is_fk:
        return f'<TD PORT="{port}"><U><FONT COLOR="orange"><I>{text} (FK)</I></FONT></U></TD>'
    if is_pk:
        return f'<TD PORT="{port}"><U>{text}</U></TD>'
    if is_fk:
        return f'<TD PORT="{port}"><FONT COLOR="orange"><I>{text} (FK)</I></FONT></TD>'
    return f'<TD PORT="{port}">{text}</TD>'

def add_table(name, attrs, color):
    label = [
        '<',
        '<TABLE BORDER="1" CELLBORDER="1" CELLSPACING="0">',
        '  <TR>',
        f'    <TD BGCOLOR="{color}" ALIGN="CENTER"><B>{name}</B></TD>'
    ]
    for (text, port, is_pk, is_fk) in attrs:
        label.append('    ' + make_attr_cell(text, port, is_pk, is_fk))
    label.append('  </TR></TABLE>')
    label.append('>')
    dot.node(name, label=''.join(label), shape="plaintext")

# === 节点 ===
add_table("Album", [
    ("album_id", "album_id", True, False),
    ("release_date", "release_date", False, False)
], "lightblue")

add_table("Track", [
    ("track_id", "track_id", True, False),
    ("title", "title", False, False),
    ("duration", "duration", False, False),
    ("genre", "genre", False, False),
    ("album_id", "album_id", False, True)
], "lightblue")

add_table("Artist", [
    ("artist_id", "artist_id", True, False),
    ("full_name", "full_name", False, False),
    ("email", "email", False, False),
    ("login_name (UQ)", "login_name", False, False),
    ("password", "password", False, False),
    ("mobile_number", "mobile_number", False, False)
], "lightblue")

add_table("Customer", [
    ("customer_id", "customer_id", True, False),
    ("full_name", "full_name", False, False),
    ("email", "email", False, False),
    ("login_name (UQ)", "login_name", False, False),
    ("password", "password", False, False),
    ("mobile_number", "mobile_number", False, False),
    ("age [non-negative]", "age", False, False),
    ("birth_date", "birth_date", False, False)
], "lightblue")

add_table("Staff", [
    ("staff_id", "staff_id", True, False),
    ("full_name", "full_name", False, False),
    ("email", "email", False, False),
    ("login_name (UQ)", "login_name", False, False),
    ("password", "password", False, False),
    ("mobile_number", "mobile_number", False, False),
    ("address", "address", False, False),
    ("compensation [0-200000]", "compensation", False, False)
], "lightblue")

add_table("Review", [
    ("review_id", "review_id", True, False),
    ("customer_id", "customer_id", False, True),
    ("track_id", "track_id", False, True),
    ("rating [1-5]", "rating", False, False),
    ("comment", "comment", False, False),
    ("created_date", "created_date", False, False),
    ("created_time", "created_time", False, False)
], "lightblue")

add_table("Playlist", [
    ("playlist_id", "playlist_id", True, False),
    ("customer_id", "customer_id", False, True),
    ("name (UQ per customer)", "name", False, False)
], "lightblue")

# 关系表（橙色）
add_table("Contributed", [
    ("artist_id", "artist_id", True, True),
    ("track_id", "track_id", True, True),
    ("role", "role", False, False)
], "lightsalmon")

add_table("Remove", [
    ("staff_id", "staff_id", True, True),
    ("review_id", "review_id", True, True),
    ("removal_reason", "removal_reason", False, False),
    ("removal_date", "removal_date", False, False),
    ("removal_time", "removal_time", False, False)
], "lightsalmon")

add_table("PlaylistItem", [
    ("playlist_id", "playlist_id", True, True),
    ("track_id", "track_id", True, True),
    ("position (UQ per playlist)", "position", False, False)
], "lightsalmon")

add_table("Listens_to", [
    ("customer_id", "customer_id", True, True),
    ("track_id", "track_id", True, True),
    ("times", "times", False, False)
], "lightsalmon")

# === 边（外键 -> 主键，端口用上下/左右，Graphviz 自动选择路径） ===
dot.edge("Track:album_id", "Album:album_id")
dot.edge("Review:customer_id", "Customer:customer_id")
dot.edge("Review:track_id", "Track:track_id")
dot.edge("Playlist:customer_id", "Customer:customer_id")
dot.edge("Contributed:artist_id", "Artist:artist_id")
dot.edge("Contributed:track_id", "Track:track_id")
dot.edge("Remove:staff_id", "Staff:staff_id")
dot.edge("Remove:review_id", "Review:review_id")
dot.edge("PlaylistItem:playlist_id", "Playlist:playlist_id")
dot.edge("PlaylistItem:track_id", "Track:track_id")
dot.edge("Listens_to:customer_id", "Customer:customer_id")
dot.edge("Listens_to:track_id", "Track:track_id")

# 输出紧凑图
dot.render("sydney_music_rm", view=True)
