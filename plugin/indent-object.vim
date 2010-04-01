onoremap <silent>ai :<C-u>cal TextObject(0, [line("."), line("."), col("."), col(".")])<CR>
onoremap <silent>ii :<C-u>cal TextObject(1, [line("."), line("."), col("."), col(".")])<CR>
vnoremap <silent>ai :<C-u>cal TextObject(0, [line("'<"), line("'>"), col("'<"), col("'>")])<CR><Esc>gv
vnoremap <silent>ii :<C-u>cal TextObject(1, [line("'<"), line("'>"), col("'<"), col("'>")])<CR><Esc>gv

function! TextObjectCount(inner, range, count)

	" Record the current state of the visual region.
	let l0 = a:range[0]
	let l1 = a:range[1]
	let c0 = a:range[2]
	let c1 = a:range[3]

	" Repeatedly increase the scope of the selection.
	let cnt = a:count
	while cnt > 0

		" Look for the minimum indentation in the current visual region.
		let idnt = 1000
		let l = l0
		while l <= l1
			let idnt = min([idnt, indent(l)])
			let l += 1
		endwhile

		" Search backward for the first line with less indent than the target
		" indent.
		let l_1 = l0
		let l_1o = l_1
		while l_1 > 0 && indent(l_1) >= idnt
			let l_1o = l_1
			let l_1 -= 1
		endwhile

		" Search forward for the first line with more indent than the target
		" indent.
		let line_cnt = line("$")
		let l2 = l1
		let l2o = l2
		while l2 <= line_cnt && indent(l2) >= idnt
			let l2o = l2
			let l2 += 1
		endwhile

		" Determine which of these extensions to include. Include neither if
		" we are selecting an 'inner' object.
		let idnt2 = max([indent(l_1), indent(l2)])
		if indent(l_1) < idnt2 || a:inner
			let l_1 = l_1o
		endif
		if indent(l2) < idnt2 || a:inner
			let l2 = l2o
		endif
		let l_1 = max([l_1, 1])
		let l2 = min([l2, line("$")])

		" Extend the columns to the start and end.
		let c_1 = 1
		let c2 = len(getline(l2))

		" Check whether the visual region has changed.
		let chg = 0
		let chg = chg || l0 != l_1
		let chg = chg || l1 != l2
		let chg = chg || c0 != c_1
		let chg = chg || c1 != c2

		" Update the vars.
		let l0 = l_1
		let l1 = l2
		let c0 = c_1
		let c1 = c2

		" If there was no change, then don't decrement the count (it didn't
		" count because it didn't do anything).
		if chg
			let cnt = cnt - 1
		else
			" Since this didn't work, push the selection back one char. This
			" will have the effect of getting the enclosing block. Do it at
			" the beginning rather than the end - the beginning is very likely
			" to be only one indentation level different.
			if l0 == 0
				return
			endif
			let c0 -= 1
			if c0 == 0
				let l0 -= 1
				let c0 = len(getline(l0))
			endif
		endif

	endwhile

	" Apply the range we have found.
	call cursor(l0, c0)
	normal! v
	call cursor(l1, c1)

endfunction

function! TextObject(inner, range)
	call TextObjectCount(a:inner, a:range, v:count1)
endfunction
