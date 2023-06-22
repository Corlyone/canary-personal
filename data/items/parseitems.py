import xml.etree.ElementTree as ET
import json

def get_attribute_value(item, key):
    attribute = item.find(f"attribute[@key='{key}']")
    if attribute is not None:
        return attribute.get("value")
    return None

def parse_item(item):
    item_data = {
        "clientId": int(item.get("id")) if item.get("id") else 0,
        "itemName": item.get("name") or "",
        "attack": get_attribute_value(item, "attack") or "",
        "armor": get_attribute_value(item, "armor") or "",
        "defense": get_attribute_value(item, "defense") or "",
        "extraDefense": get_attribute_value(item, "extradef") or "",
        "shootRange": get_attribute_value(item, "range") or "",
        "hitChance": get_attribute_value(item, "hitchance") or "",
        "weight": int(get_attribute_value(item, "weight")) if get_attribute_value(item, "weight") else 0,
        "desc": get_attribute_value(item, "description") or "",
        "uid": int(item.get("id")) if item.get("id") else 0,
        "itemType": "Common",
        "stackable": True,
        "action": "new"
    }
    
    name = item.get("name")
    if name:
        if "helmet" in name.lower():
            item_data["type"] = "Helmet"
        elif "armor" in name.lower():
            item_data["type"] = "Armor"
        elif "shield" in name.lower():
            item_data["type"] = "Shield"
        elif "sword" in name.lower():
            item_data["type"] = "Sword"
        elif "legs" in name.lower():
            item_data["type"] = "Legs"
        elif "boots" in name.lower():
            item_data["type"] = "Boots"
        elif "ring" in name.lower():
            item_data["type"] = "Ring"
        elif "necklace" in name.lower():
            item_data["type"] = "Necklace"
        elif "boots" in name.lower():
            item_data["type"] = "Boots"

    weapon_type = get_attribute_value(item, "weaponType")
    if weapon_type:
        item_data["type"] = weapon_type.capitalize()
        
    return item_data

def parse_xml_file(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()

    tooltips = []
    for item in root.findall("item"):
        if get_attribute_value(item, "weight") is not None:
            item_data = parse_item(item)
            tooltips.append(item_data)

    return tooltips


def generate_lua_table(tooltips):
    lua_table = "local tooltips = {\n"
    for tooltip in tooltips:
        lua_table += "    {\n"
        for key, value in tooltip.items():
            lua_table += f"        {key} = {repr(value)},\n"
        lua_table += "    },\n"
    lua_table += "}\n"
    return lua_table


def main():
    xml_file = "items.xml"
    lua_file = "tooltips.lua"

    tooltips = parse_xml_file(xml_file)
    lua_table = generate_lua_table(tooltips)

    with open(lua_file, "w") as file:
        file.write(lua_table)

    print(f"Se generó el archivo Lua: {lua_file}")


if __name__ == "__main__":
    main()
