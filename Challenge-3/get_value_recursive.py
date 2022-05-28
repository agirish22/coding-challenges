object = {"a":{"b":{"c":"d"}}}
key = "a/b/c"
def my_function(object, key):
    if not object:
        print("empty object")
        return
    if not key:
        print("empty keys")
        return
    keys = key.split("/",1)
    index=keys[0]
    if len(keys) > 1 and index in object:
        my_function(object[index], keys[1])
    elif index in object:
        print(object[index])
    else:
        print("key not found")

my_function(object, key)
