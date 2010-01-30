import Ports

COLOR_BLACK    := 0x0
COLOR_BLUE     := 0x1
COLOR_GREEN    := 0x2
COLOR_CYAN     := 0x3
COLOR_RED      := 0x4
COLOR_MAGENTA  := 0x5
COLOR_BROWN    := 0x6
COLOR_LGREY    := 0x7
COLOR_DGREY    := 0x8
COLOR_LBLUE    := 0x9
COLOR_LGREEN   := 0xa
COLOR_LCYAN    := 0xb
COLOR_LRED     := 0xc
COLOR_LMAGENTA := 0xd
COLOR_YELLOW   := 0xe
COLOR_WHITE    := 0xf

VIDEO_MEMORY := 0xb8000 as UInt16*

attr: UInt8
cursor_x: Int
cursor_y: Int

halInitDisplay: func {
  // default to light grey on black like the BIOS
  halDisplaySetAttr(COLOR_LGREY, COLOR_BLACK)
  halDisplayClearScreen()
}

halDisplaySetAttr: func (foreground, background: Int) {
  attr = (foreground & 0xf) | background << 4
}

halDisplayClearScreen: func {
  for (row in 0..25) {
    for (col in 0..80) {
      VIDEO_MEMORY[row * 80 + col] = ' ' | attr << 8
    }
  }
  cursor_x = 0
  cursor_y = 0
  halDisplayUpdateCursor()
}

halDisplayUpdateCursor: func {
  i := cursor_y * 80 + cursor_x
  halOutPort(0x3d4, 14)
  halOutPort(0x3d5, i >> 8)
  halOutPort(0x3d4, 15)
  halOutPort(0x3d5, i)
}

halDisplayChar: unmangled func (chr: Char) {
  // Handle a backspace, by moving the cursor back one space
  if (chr == '\b') {
    if (cursor_x != 0) cursor_x -= 1
  }

  // Handles a tab by incrementing the cursor's x, but only
  // to a point that will make it divisible by 8
  else if (chr == '\t') {
    cursor_x = (cursor_x + 8) & ~(8 - 1)
  }

  // Handles a 'Carriage Return', which simply brings the
  // cursor back to the margin
  else if (chr == '\r') {
    cursor_x = 0
  }

  // We handle our newlines the way DOS and the BIOS do: we
  // treat it as if a 'CR' was also there, so we bring the
  // cursor to the margin and we increment the 'y' value
  else if (chr == '\n') {
    cursor_x = 0
    cursor_y += 1
  }

  // Any character greater than and including a space, is a
  // printable character. The equation for finding the index
  // in a linear chunk of memory can be represented by:
  // Index = [(y * width) + x]
  else if(chr >= ' ') {
    i := cursor_y * 80 + cursor_x
    VIDEO_MEMORY[i] = chr | attr << 8
    cursor_x += 1
  }

  // If the cursor has reached the edge of the screen's width, we
  // insert a new line in there
  if(cursor_x >= 80) {
    cursor_x = 0
    cursor_y += 1
  }

  halDisplayUpdateCursor()
}

halDisplayString: func (str: String) {
  for (i in 0..str length()) {
    halDisplayChar(str[i])
  }
}

