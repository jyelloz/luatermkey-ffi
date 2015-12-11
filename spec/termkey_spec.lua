local termkey = require('termkey')

describe(
  "TermKey",
  function()

    local term
    local key

    before_each(
      function()
        term = termkey.TermKeyAbstract('test', 0, 0)
        key = termkey.TermKeyKey()
      end
    )

    after_each(
      function()
        term = nil
        key = nil
      end
    )

    describe(
      "READ",
      function()

        local keychar = 'a'
        local keychar_byte = keychar:byte()

        local ascii_del_byte = 0x7f
        local ascii_del = string.char(ascii_del_byte)

        it(
          "ensures the character 'a' produces a UNICODE event type",
          function()

            term:push_bytes(keychar, #keychar)
            term:advisereadable()
            term:getkey_force(key)

            assert.equals(termkey.Type.UNICODE, key.type)

          end
        )

        it(
          "ensures you can access a unicode event's codepoint",
          function()

            term:push_bytes(keychar, #keychar)
            term:advisereadable()
            term:getkey_force(key)

            assert.equals(('a'):byte(), key.code.codepoint)

          end
        )

        it(
          "ensures you can access a unicode event's text value",
          function()

            term:push_bytes(keychar, #keychar)
            term:advisereadable()
            term:getkey_force(key)

            assert.equals('a', key:text())

          end
        )

        it(
          "ensures ASCII DEL produces a KEYSYM event",
          function()

            term:push_bytes(ascii_del, #ascii_del)
            term:advisereadable()
            term:getkey_force(key)

            assert.equals(termkey.Type.KEYSYM, key.type)

          end
        )

        it(
          "ensures ASCII DEL is read as TERMKEY_SYM_DEL",
          function()

            term:push_bytes(ascii_del, #ascii_del)
            term:advisereadable()
            term:getkey_force(key)

            assert.equals(termkey.Sym.DEL, key.code.sym)

          end
        )

      end
    )

  end
)

