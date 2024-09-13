import pymysql

# Jaro-Winkler 유사도 계산 함수
def jaro_winkler(str1: str, str2: str) -> float:
    def get_matched_characters(_str1: str, _str2: str) -> str:
        matched = []
        limit = min(len(_str1), len(_str2)) // 2
        _str2_list = list(_str2)

        for i, l in enumerate(_str1):
            left = max(0, i - limit)
            right = min(i + limit + 1, len(_str2_list))
            if l in _str2_list[left:right]:
                matched.append(l)
                _str2_list[_str2_list.index(l)] = None

        return "".join(matched)

    matching_1 = get_matched_characters(str1, str2)
    matching_2 = get_matched_characters(str2, str1)
    match_count = len(matching_1)

    transpositions = sum(c1 != c2 for c1, c2 in zip(matching_1, matching_2)) // 2

    if not match_count:
        jaro = 0.0
    else:
        jaro = (1 / 3) * (
            match_count / len(str1) +
            match_count / len(str2) +
            (match_count - transpositions) / match_count
        )

    prefix_len = 0
    for c1, c2 in zip(str1[:4], str2[:4]):
        if c1 == c2:
            prefix_len += 1
        else:
            break

    return jaro + 0.1 * prefix_len * (1 - jaro)

def compare_jaro_winkler(similarities_list: list, input_word: str):
    similarities = []
    
    # similarities_list에서 name과 유사도 점수 추출
    for name, _ in similarities_list: 
        # name과 input_word 비교
        similarity = jaro_winkler(name, input_word)  
        # 소수점 2자리까지만 출력함 
        similarities.append((name, round(similarity, 2)))

    # 유사도 기준 필터링 및 정렬
    second_round_similarities = []
    for name, similarity in similarities:
        if similarity > 0.7 and abs(len(input_word) - len(name)) < 3:
            second_round_similarities.append((name, similarity))
        
    return second_round_similarities

#자카드 알고리즘
def calculate_jaccard_similarity(doc1: str, doc2: str) -> float:
    doc1_tokenized = set(doc1)
    doc2_tokenized = set(doc2)
    
    doc_union = doc1_tokenized.union(doc2_tokenized)
    doc_intersection = doc1_tokenized.intersection(doc2_tokenized)
    
    if len(doc_union) == 0:
        return 0.0
    
    return len(doc_intersection) / len(doc_union)

def find_similar_names(input_word: str, name_list: list) -> list:
    first_round_similarities = []
    
    for name in name_list:
        similarity = calculate_jaccard_similarity(name, input_word)
        if similarity > 0.5:
            first_round_similarities.append((name, similarity))
    
    first_round_similarities.sort(key=lambda x: x[1], reverse=True)
    # 결과 출력 (순위 포함)
    #for rank, (name, similarity) in enumerate(first_round_similarities, start=1):
    #    print(f"{rank}등 {name}, Jaccard Similarity: {similarity:.2f}")

    return first_round_similarities

def select_by_first_word(name: str) -> list:
    conn = pymysql.connect(
    host='localhost',
    user='ABO',
    password='!@ABOkSj0812@!',
    database='ABO',
    charset='utf8'
    )
    cur = conn.cursor()
    first_word = name[0]
    try:
        query = "select name from PackageName where name like %s"
        cur.execute(query, (first_word + '%',))
        
        # 조회한 모든 결과 results에 저장함
        results = cur.fetchall()
        
        #각각 따로 호출할 땐 아래 주석 삭제
        #return [result[0] for result in results]
        
        # 함께 호출 시 추가함
        name_list = [result[0] for result in results]
        
        # find_similar_names 호출
        similarities_list = find_similar_names(name, name_list)
        #compare_jaro_winkler 호출
        second_round_similarities = compare_jaro_winkler(similarities_list, name)
        cur.close()
        conn.close()
        return second_round_similarities
    
    except pymysql.MySQLError as e:
        print(f"select error: {e}")        
        # 결과 없으면 빈 리스트 반환 
        # 나중에 아예 강제 종료로 바꿔도 될 듯
        cur.close()
        conn.close() 
        return print("빈 리스트임")
    






# 따로 호출 시 호출 변수 name_list로 변경



# 따로 호출 시 주석 해제
#similarities_list = find_similar_names(input_word, name_list)
#second_round_similarities = compare_jaro_winkler(similarities_list, input_word)

# 최종 결과 출력 및 순위 매기기
#for rank, (name, similarity) in enumerate(second_round_similarities, start=1):
#    print(f"{rank}등 {name}, Jaro-Winkler Similarity: {similarity:.2f}")



