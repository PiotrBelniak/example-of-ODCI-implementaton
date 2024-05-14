CREATE OR REPLACE EDITIONABLE TYPE "C##METEO"."SECONDBESTPRESSIMPL" as object
(best_val NUMBER,
secbest NUMBER,
static function ODCIAggregateInitialize(sctx IN OUT SecondBestPressImpl) return number,
member function ODCIAggregateIterate(self IN OUT SecondBestPressImpl, value IN METEO_T) return number,
member function ODCIAggregateTerminate(self IN OUT SecondBestPressImpl, returnVal OUT number, flags IN NUMBER) return number,
member function ODCIAggregateMerge(self IN OUT SecondBestPressImpl, ctx2 IN SecondBestPressImpl) return number);
/
CREATE OR REPLACE EDITIONABLE TYPE BODY "C##METEO"."SECONDBESTPRESSIMPL" 
IS
    static function ODCIAggregateInitialize(sctx IN OUT SecondBestPressImpl) return number
    IS
    BEGIN
        sctx:=SecondBestPressImpl(1200,1199);
        return ODCIConst.Success;
    END ODCIAggregateInitialize;
    member function ODCIAggregateIterate(self IN OUT SecondBestPressImpl, value IN METEO_T) return number
    IS
        curval NUMBER;
    BEGIN
        FOR indx IN value.Zonereadings.FIRST..value.Zonereadings.LAST LOOP
            IF ABS(value.Zonereadings(indx).pressure-1013.25)<ABS(curval-1013.25) OR curval IS NULL THEN
                curval:=value.Zonereadings(indx).pressure;
            END IF;
        END LOOP;
        IF ABS(curval-1013.25)<ABS(self.best_val-1013.25) THEN
            self.secbest:=self.best_val;
            self.best_val:=curval;
        ELSIF ABS(curval-1013.25)> ABS(self.best_val-1013.25) AND ABS(curval-1013.25)<ABS(self.secbest-1013.25) THEN
            self.secbest:=curval;
        END IF;
        return ODCICOnst.Success;
    END ODCIAggregateIterate;
    member function ODCIAggregateTerminate(self IN OUT SecondBestPressImpl, returnVal OUT number, flags IN NUMBER) return number
    IS
    BEGIN
        IF self.secbest=1199 OR self.secbest=1200 THEN
            returnVal:=self.best_val;
        ELSE
            returnVal:=self.secbest;
        END IF;
        return ODCIConst.Success;
    END ODCIAggregateTerminate;

    member function ODCIAggregateMerge(self IN OUT SecondBestPressImpl, ctx2 IN SecondBestPressImpl) return number
    IS
    BEGIN
        IF ABS(ctx2.secbest-1013.25)<ABS(self.best_val-1013.25) THEN
            self.secbest:=ctx2.secbest;
            self.best_val:=ctx2.best_val;
        ELSIF ABS(ctx2.best_val-1013.25)<ABS(self.best_val-1013.25) THEN
            self.secbest:=self.best_val;
            self.best_val:=ctx2.best_val;
        ELSIF ABS(ctx2.best_val-1013.25)<ABS(self.secbest-1013.25) THEN
            self.secbest:=ctx2.best_val;
        END IF;
        return ODCIConst.Success;
    END ODCIAggregateMerge;
END;

/
